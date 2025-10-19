// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title DEMI Token with Vesting
 * @notice DEMI token with infinite supply, presale mechanism, and co-founder vesting
 * @dev Owner can mint new tokens (50/50 split), co-founder tokens vest over 24 months
 */

// Vesting Contract for Co-founder
contract TokenVesting {
    address public beneficiary;
    address public owner;
    IERC20 public token;
    
    uint256 public totalAmount;
    uint256 public startTime;
    uint256 public duration; // 24 months in seconds
    uint256 public released;
    bool public revoked;
    
    event TokensReleased(uint256 amount);
    event VestingRevoked(uint256 amountReturned);
    
    constructor(
        address _beneficiary,
        address _token,
        uint256 _totalAmount,
        uint256 _duration
    ) {
        require(_beneficiary != address(0), "Invalid beneficiary");
        beneficiary = _beneficiary;
        owner = msg.sender;
        token = IERC20(_token);
        totalAmount = _totalAmount;
        startTime = block.timestamp;
        duration = _duration;
    }
    
    function releasableAmount() public view returns (uint256) {
        return vestedAmount() - released;
    }
    
    function vestedAmount() public view returns (uint256) {
        if (revoked) {
            return released;
        }
        
        uint256 elapsed = block.timestamp - startTime;
        
        if (elapsed >= duration) {
            return totalAmount;
        }
        
        return (totalAmount * elapsed) / duration;
    }
    
    function release() external {
        require(!revoked, "Vesting revoked");
        
        uint256 amount = releasableAmount();
        require(amount > 0, "No tokens to release");
        
        released += amount;
        require(token.transfer(beneficiary, amount), "Transfer failed");
        
        emit TokensReleased(amount);
    }
    
    function revoke() external {
        require(msg.sender == owner, "Only owner");
        require(!revoked, "Already revoked");
        
        revoked = true;
        
        uint256 unvested = totalAmount - released;
        if (unvested > 0) {
            require(token.transfer(owner, unvested), "Transfer failed");
        }
        
        emit VestingRevoked(unvested);
    }
    
    function getRemainingVested() external view returns (uint256) {
        return totalAmount - released;
    }
}

contract DEMI is ERC20, Ownable, ReentrancyGuard {
    
    // No max supply - infinite supply
    
    // Sale configuration
    uint256 public tokenPrice; // Price in USD (6 decimals) - initially $0.01
    bool public saleActive;
    
    // Supported payment tokens
    IERC20 public immutable USDT;
    IERC20 public immutable USDC;
    
    // Tracking
    uint256 public totalSold;
    uint256 public totalRaisedUSDT;
    uint256 public totalRaisedUSDC;
    
    // Vesting contract
    TokenVesting public cofounderVesting;
    
    // Events
    event TokensPurchased(
        address indexed buyer,
        uint256 demiAmount,
        uint256 paymentAmount,
        address paymentToken
    );
    event TokensMinted(uint256 amountToOwner, uint256 amountToContract);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);
    event SaleStatusChanged(bool active);
    event FundsWithdrawn(address token, uint256 amount);
    event CofounderVestingCreated(address vestingContract, uint256 amount);
    
    /**
     * @notice Constructor - deploys DEMI token and sets up initial distribution
     * @param _usdt Address of USDT token on Polygon
     * @param _usdc Address of USDC token on Polygon
     * @param _cofounder Address of co-founder for vesting
     */
    constructor(
        address _usdt,
        address _usdc,
        address _cofounder
    ) ERC20("Demi", "DEMI") Ownable(msg.sender) {
        require(_cofounder != address(0), "Invalid cofounder address");
        
        // Set payment tokens
        USDT = IERC20(_usdt);
        USDC = IERC20(_usdc);
        
        // Initial distribution: 3.3 billion tokens
        // 1.65B to owner
        _mint(owner(), 1_650_000_000 * 10**18);
        
        // 1.65B for presale/circulation
        // 165M goes to vesting contract for cofounder
        // 1.485B stays in contract for presale
        
        // Create vesting contract for cofounder (24 months)
        uint256 cofounderAmount = 165_000_000 * 10**18;
        uint256 vestingDuration = 730 days; // 24 months
        
        cofounderVesting = new TokenVesting(
            _cofounder,
            address(this),
            cofounderAmount,
            vestingDuration
        );
        
        // Mint tokens for presale + vesting
        _mint(address(this), 1_485_000_000 * 10**18); // For presale
        _mint(address(cofounderVesting), cofounderAmount); // For vesting
        
        // Initialize sale
        tokenPrice = 10000; // $0.01 in 6 decimals
        saleActive = true;
        
        emit CofounderVestingCreated(address(cofounderVesting), cofounderAmount);
    }
    
    /**
     * @notice Mint new tokens (owner only)
     * @param amount Total amount to mint (will be split 50/50)
     * @dev 50% goes to owner, 50% goes to contract for presale
     */
    function mintTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(amount % 2 == 0, "Amount must be even for 50/50 split");
        
        uint256 half = amount / 2;
        
        _mint(owner(), half);
        _mint(address(this), half);
        
        emit TokensMinted(half, half);
    }
    
    /**
     * @notice Calculate how many DEMI tokens for given USD amount
     * @param usdAmount Amount in USD (6 decimals)
     * @return Number of DEMI tokens (18 decimals)
     */
    function calculateTokenAmount(uint256 usdAmount) public view returns (uint256) {
        return (usdAmount * 10**18) / tokenPrice;
    }
    
    /**
     * @notice Buy DEMI with USDT
     * @param usdtAmount Amount of USDT to spend (6 decimals)
     */
    function buyWithUSDT(uint256 usdtAmount) external nonReentrant {
        require(saleActive, "Sale not active");
        require(usdtAmount > 0, "Amount must be greater than 0");
        
        uint256 demiAmount = calculateTokenAmount(usdtAmount);
        require(demiAmount <= balanceOf(address(this)), "Insufficient DEMI in contract");
        
        require(
            USDT.transferFrom(msg.sender, address(this), usdtAmount),
            "USDT transfer failed"
        );
        
        _transfer(address(this), msg.sender, demiAmount);
        
        totalSold += demiAmount;
        totalRaisedUSDT += usdtAmount;
        
        emit TokensPurchased(msg.sender, demiAmount, usdtAmount, address(USDT));
    }
    
    /**
     * @notice Buy DEMI with USDC
     * @param usdcAmount Amount of USDC to spend (6 decimals)
     */
    function buyWithUSDC(uint256 usdcAmount) external nonReentrant {
        require(saleActive, "Sale not active");
        require(usdcAmount > 0, "Amount must be greater than 0");
        
        uint256 demiAmount = calculateTokenAmount(usdcAmount);
        require(demiAmount <= balanceOf(address(this)), "Insufficient DEMI in contract");
        
        require(
            USDC.transferFrom(msg.sender, address(this), usdcAmount),
            "USDC transfer failed"
        );
        
        _transfer(address(this), msg.sender, demiAmount);
        
        totalSold += demiAmount;
        totalRaisedUSDC += usdcAmount;
        
        emit TokensPurchased(msg.sender, demiAmount, usdcAmount, address(USDC));
    }
    
    // ========== OWNER FUNCTIONS ==========
    
    function withdrawUSDT() external onlyOwner {
        uint256 balance = USDT.balanceOf(address(this));
        require(balance > 0, "No USDT to withdraw");
        require(USDT.transfer(owner(), balance), "USDT transfer failed");
        
        emit FundsWithdrawn(address(USDT), balance);
    }
    
    function withdrawUSDC() external onlyOwner {
        uint256 balance = USDC.balanceOf(address(this));
        require(balance > 0, "No USDC to withdraw");
        require(USDC.transfer(owner(), balance), "USDC transfer failed");
        
        emit FundsWithdrawn(address(USDC), balance);
    }
    
    function withdrawUnsoldTokens() external onlyOwner {
        uint256 balance = balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        _transfer(address(this), owner(), balance);
    }
    
    function setTokenPrice(uint256 newPrice) external onlyOwner {
        require(newPrice > 0, "Price must be greater than 0");
        uint256 oldPrice = tokenPrice;
        tokenPrice = newPrice;
        
        emit PriceUpdated(oldPrice, newPrice);
    }
    
    function setSaleActive(bool _active) external onlyOwner {
        saleActive = _active;
        emit SaleStatusChanged(_active);
    }
    
    /**
     * @notice Revoke co-founder vesting (if not performing)
     * @dev Unvested tokens return to owner
     */
    function revokeCofounderVesting() external onlyOwner {
        cofounderVesting.revoke();
    }
    
    // ========== VIEW FUNCTIONS ==========
    
    function getSaleStats() external view returns (
        uint256 currentPrice,
        uint256 tokensSold,
        uint256 raisedUSDT,
        uint256 raisedUSDC,
        uint256 remainingTokens,
        bool isActive
    ) {
        return (
            tokenPrice,
            totalSold,
            totalRaisedUSDT,
            totalRaisedUSDC,
            balanceOf(address(this)),
            saleActive
        );
    }
    
    function getContractBalances() external view returns (
        uint256 usdtBalance,
        uint256 usdcBalance
    ) {
        return (
            USDT.balanceOf(address(this)),
            USDC.balanceOf(address(this))
        );
    }
    
    function getCofounderVestingInfo() external view returns (
        address vestingContract,
        address beneficiary,
        uint256 totalAmount,
        uint256 released,
        uint256 releasable,
        bool isRevoked
    ) {
        return (
            address(cofounderVesting),
            cofounderVesting.beneficiary(),
            cofounderVesting.totalAmount(),
            cofounderVesting.released(),
            cofounderVesting.releasableAmount(),
            cofounderVesting.revoked()
        );
    }
}
