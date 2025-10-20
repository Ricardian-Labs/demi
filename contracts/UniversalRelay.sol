// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    
    function getAmountsOut(uint256 amountIn, address[] calldata path) 
        external view returns (uint256[] memory amounts);
}

interface ITargetContract {
    function buyWithUSDC(uint256 amount) external;
    function buyWithUSDT(uint256 amount) external;
}

contract UniversalRelay is Ownable, ReentrancyGuard, EIP712 {
    using ECDSA for bytes32;

    struct RelayRequest {
        address from;
        address to;
        address paymentToken;
        uint256 amount;
        uint256 nonce;
        uint256 deadline;
        address project;
        bytes data;
    }

    bytes32 private constant RELAY_REQUEST_TYPEHASH = keccak256(
        "RelayRequest(address from,address to,address paymentToken,uint256 amount,uint256 nonce,uint256 deadline,address project,bytes data)"
    );

    mapping(address => uint256) public nonces;
    mapping(address => bool) public supportedTokens;
    mapping(address => uint256) public projectFees;
    
    address public immutable USDC;
    address public immutable WETH;
    address public immutable NATIVE_TOKEN;
    address public constant UNISWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    
    uint256 public baseFee;
    uint256 public constant GAS_ESTIMATE = 200000;
    
    event RelayExecuted(
        address indexed from,
        address indexed to,
        address paymentToken,
        uint256 amount,
        uint256 feeCharged
    );
    
    event TokenAdded(address indexed token, bool isStablecoin);
    event TokenRemoved(address indexed token);
    event ProjectFeeUpdated(address indexed project, uint256 newFee);
    event BaseFeeUpdated(uint256 newBaseFee);

    constructor(
        address _usdc,
        address _weth,
        address _nativeToken,
        uint256 _baseFee
    ) EIP712("UniversalRelay", "1") Ownable(msg.sender) {
        USDC = _usdc;
        WETH = _weth;
        NATIVE_TOKEN = _nativeToken;
        baseFee = _baseFee;
        
        supportedTokens[_usdc] = true;
    }

    function executeRelay(
        RelayRequest calldata request,
        bytes calldata signature
    ) external nonReentrant {
        require(block.timestamp <= request.deadline, "Request expired");
        require(supportedTokens[request.paymentToken], "Token not supported");
        require(nonces[request.from] == request.nonce, "Invalid nonce");
        
        bytes32 structHash = _hashTypedDataV4(_hashRelayRequest(request));
        address signer = structHash.recover(signature);
        require(signer == request.from, "Invalid signature");
        
        nonces[request.from]++;
        
        uint256 totalFeeInUsd = _calculateTotalFeeInUsd(request.project);
        uint256 tokenPriceInUsd = getTokenPriceInUsd(request.paymentToken);
        
        uint256 feeInToken;
        if (tokenPriceInUsd > 0) {
            feeInToken = (totalFeeInUsd * 1e18) / tokenPriceInUsd;
        } else {
            feeInToken = (totalFeeInUsd * 1e6) / 1e18;
        }
        
        require(request.amount > feeInToken, "Amount too small for fees");
        
        bool transferSuccess = IERC20(request.paymentToken).transferFrom(
            request.from,
            address(this),
            request.amount
        );
        require(transferSuccess, "Transfer failed");
        
        uint256 amountAfterFee = request.amount - feeInToken;
        
        uint256 balanceBefore = IERC20(request.to).balanceOf(address(this));
        
        IERC20(request.paymentToken).approve(request.to, amountAfterFee);
        
        if (request.paymentToken == USDC) {
            ITargetContract(request.to).buyWithUSDC(amountAfterFee);
        } else {
            ITargetContract(request.to).buyWithUSDT(amountAfterFee);
        }
        
        uint256 balanceAfter = IERC20(request.to).balanceOf(address(this));
        uint256 tokensReceived = balanceAfter - balanceBefore;
        
        require(tokensReceived > 0, "No tokens received");
        
        bool forwardSuccess = IERC20(request.to).transfer(request.from, tokensReceived);
        require(forwardSuccess, "Forward failed");
        
        emit RelayExecuted(
            request.from,
            request.to,
            request.paymentToken,
            request.amount,
            feeInToken
        );
    }

    function getTokenPriceInUsd(address token) public view returns (uint256) {
        if (token == USDC) {
            return 1e18;
        }
        
        if (token == WETH || token == NATIVE_TOKEN) {
            address[] memory pathDirect = new address[](2);
            pathDirect[0] = WETH;
            pathDirect[1] = USDC;
            
            try IUniswapV2Router(UNISWAP_ROUTER).getAmountsOut(1e18, pathDirect) returns (uint256[] memory amounts) {
                return amounts[1] * 1e12;
            } catch {
                return 0;
            }
        }
        
        address[] memory pathIndirect = new address[](3);
        pathIndirect[0] = token;
        pathIndirect[1] = WETH;
        pathIndirect[2] = USDC;
        
        try IUniswapV2Router(UNISWAP_ROUTER).getAmountsOut(1e18, pathIndirect) returns (uint256[] memory amounts) {
            return amounts[2] * 1e12;
        } catch {
            return 0;
        }
    }

    function _calculateTotalFeeInUsd(address project) internal view returns (uint256) {
        uint256 gasCostWei = GAS_ESTIMATE * tx.gasprice;
        uint256 nativeTokenPrice = getTokenPriceInUsd(NATIVE_TOKEN);
        
        uint256 gasCostInUsd = (gasCostWei * nativeTokenPrice) / 1e18;
        
        uint256 projectFee = projectFees[project];
        
        return baseFee + gasCostInUsd + projectFee;
    }

    function _hashRelayRequest(RelayRequest calldata request) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            RELAY_REQUEST_TYPEHASH,
            request.from,
            request.to,
            request.paymentToken,
            request.amount,
            request.nonce,
            request.deadline,
            request.project,
            keccak256(request.data)
        ));
    }

    function addToken(address token, bool isStablecoin) external onlyOwner {
        supportedTokens[token] = true;
        emit TokenAdded(token, isStablecoin);
    }

    function removeToken(address token) external onlyOwner {
        supportedTokens[token] = false;
        emit TokenRemoved(token);
    }

    function setProjectFee(address project, uint256 fee) external onlyOwner {
        projectFees[project] = fee;
        emit ProjectFeeUpdated(project, fee);
    }

    function setBaseFee(uint256 newBaseFee) external onlyOwner {
        baseFee = newBaseFee;
        emit BaseFeeUpdated(newBaseFee);
    }

    function withdrawFees(address token, uint256 amount) external onlyOwner {
        bool success = IERC20(token).transfer(owner(), amount);
        require(success, "Withdrawal failed");
    }

    receive() external payable {}
}
