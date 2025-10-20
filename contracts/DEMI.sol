// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TokenVesting {
    address public beneficiary;
    address public owner;
    IERC20 public token;
    uint256 public totalAmount;
    uint256 public startTime;
    uint256 public duration;
    uint256 public released;
    bool public revoked;
    
    event TokensReleased(uint256 amount);
    event VestingRevoked(uint256 amountReturned);
    
    constructor(address _beneficiary, address _token, uint256 _totalAmount, uint256 _duration) {
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
        if (revoked) return released;
        uint256 elapsed = block.timestamp - startTime;
        if (elapsed >= duration) return totalAmount;
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
    
    uint256 public tokenPrice;
    bool public saleActive;
    IERC20 public immutable USDT;
    IERC20 public immutable USDC;
    uint256 public totalSold;
    uint256 public totalRaisedUSDT;
    uint256 public totalRaisedUSDC;
    TokenVesting public cofounderVesting;
    
    event TokensPurchased(address indexed buyer, uint256 demiAmount, uint256 paymentAmount, address paymentToken);
    event TokensMinted(uint256 amountToOwner, uint256 amountToContract);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);
    event SaleStatusChanged(bool active);
    event FundsWithdrawn(address token, uint256 amount);
    event CofounderVestingCreated(address vestingContract, uint256 amount);
    
    constructor(
        address _usdt,
        address _usdc,
        address _cofounder
    ) ERC20("Demi", "DEMI") Ownable(msg.sender) {
        require(_cofounder != address(0), "Invalid cofounder");
        
        USDT = IERC20(_usdt);
        USDC = IERC20(_usdc);
        
        _mint(owner(), 1_650_000_000 * 10**18);
        
        uint256 cofounderAmount = 165_000_000 * 10**18;
        cofounderVesting = new TokenVesting(_cofounder, address(this), cofounderAmount, 730 days);
        
        _mint(address(this), 1_485_000_000 * 10**18);
        _mint(address(cofounderVesting), cofounderAmount);
        
        tokenPrice = 10000;
        saleActive = true;
        
        emit CofounderVestingCreated(address(cofounderVesting), cofounderAmount);
    }
    
    function mintTokens(uint256 amount) external onlyOwner {
        require(amount > 0 && amount % 2 == 0, "Invalid amount");
        uint256 half = amount / 2;
        _mint(owner(), half);
        _mint(address(this), half);
        emit TokensMinted(half, half);
    }
    
    function calculateTokenAmount(uint256 usdAmount) public view returns (uint256) {
        return (usdAmount * 10**18) / tokenPrice;
    }
    
    function buyWithUSDT(uint256 usdtAmount) external nonReentrant {
        require(saleActive, "Sale not active");
        require(usdtAmount > 0, "Amount must be greater than 0");
        uint256 demiAmount = calculateTokenAmount(usdtAmount);
        require(demiAmount <= balanceOf(address(this)), "Insufficient DEMI");
        require(USDT.transferFrom(msg.sender, address(this), usdtAmount), "Transfer failed");
        _transfer(address(this), msg.sender, demiAmount);
        totalSold += demiAmount;
        totalRaisedUSDT += usdtAmount;
        emit TokensPurchased(msg.sender, demiAmount, usdtAmount, address(USDT));
    }
    
    function buyWithUSDC(uint256 usdcAmount) external nonReentrant {
        require(saleActive, "Sale not active");
        require(usdcAmount > 0, "Amount must be greater than 0");
        uint256 demiAmount = calculateTokenAmount(usdcAmount);
        require(demiAmount <= balanceOf(address(this)), "Insufficient DEMI");
        require(USDC.transferFrom(msg.sender, address(this), usdcAmount), "Transfer failed");
        _transfer(address(this), msg.sender, demiAmount);
        totalSold += demiAmount;
        totalRaisedUSDC += usdcAmount;
        emit TokensPurchased(msg.sender, demiAmount, usdcAmount, address(USDC));
    }
    
    function setPrice(uint256 newPrice) external onlyOwner {
        uint256 oldPrice = tokenPrice;
        tokenPrice = newPrice;
        emit PriceUpdated(oldPrice, newPrice);
    }
    
    function setSaleStatus(bool active) external onlyOwner {
        saleActive = active;
        emit SaleStatusChanged(active);
    }
    
    function withdrawUSDT() external onlyOwner {
        uint256 balance = USDT.balanceOf(address(this));
        require(balance > 0, "No USDT");
        require(USDT.transfer(owner(), balance), "Transfer failed");
        emit FundsWithdrawn(address(USDT), balance);
    }
    
    function withdrawUSDC() external onlyOwner {
        uint256 balance = USDC.balanceOf(address(this));
        require(balance > 0, "No USDC");
        require(USDC.transfer(owner(), balance), "Transfer failed");
        emit FundsWithdrawn(address(USDC), balance);
    }
    
    function withdrawUnsoldTokens(uint256 amount) external onlyOwner {
        require(amount <= balanceOf(address(this)), "Insufficient balance");
        _transfer(address(this), owner(), amount);
    }
}
