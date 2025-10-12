
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title DEMI Token
 * @notice Single contract for DEMI token with built-in sale mechanism
 * @dev Secure sale system with owner withdrawal controls
 */
contract DEMI is ERC20, Ownable, ReentrancyGuard {
    
    // Token configuration
    uint256 public constant TOTAL_SUPPLY = 3_300_000_000 * 10**18; // 3.3 billion DEMI
    
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
    
    // Events
    event TokensPurchased(
        address indexed buyer,
        uint256 demiAmount,
        uint256 paymentAmount,
        address paymentToken
    );
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);
    event SaleStatusChanged(bool active);
    event FundsWithdrawn(address token, uint256 amount);
    
    /**
     * @notice Constructor - deploys DEMI token and sets up sale
     * @param _usdt Address of USDT token on Polygon
     * @param _usdc Address of USDC token on Polygon
     */
    constructor(
        address _usdt,
        address _usdc
    ) ERC20("Demi", "DEMI") Ownable(msg.sender) {
        // Mint total supply to contract
        _mint(address(this), TOTAL_SUPPLY);
        
        // Set payment tokens
        USDT = IERC20(_usdt);
        USDC = IERC20(_usdc);
        
        // Initialize sale
        tokenPrice = 10000; // $0.01 in 6 decimals
        saleActive = true;
    }
    
    /**
     * @notice Calculate how many DEMI tokens for given USD amount
     * @param usdAmount Amount in USD (6 decimals)
     * @return Number of DEMI tokens (18 decimals)
     */
    function calculateTokenAmount(uint256 usdAmount) public view returns (uint256) {
        // usdAmount (6 decimals) * 10^18 / tokenPrice (6 decimals) = DEMI tokens (18 decimals)
        return (usdAmount * 10**18) / tokenPrice;
    }
    
    /**
     * @notice Buy DEMI with USDT
     * @param usdtAmount Amount of USDT to spend (6 decimals)
     */
    function buyWithUSDT(uint256 usdtAmount) external nonReentrant {
        require(saleActive, "Sale not active");
        require(usdtAmount > 0, "Amount must be greater than 0");
        
        // Calculate DEMI to send
        uint256 demiAmount = calculateTokenAmount(usdtAmount);
        require(demiAmount <= balanceOf(address(this)), "Insufficient DEMI in contract");
        
        // Transfer USDT from buyer to this contract
        require(
            USDT.transferFrom(msg.sender, address(this), usdtAmount),
            "USDT transfer failed"
        );
        
        // Transfer DEMI to buyer
        _transfer(address(this), msg.sender, demiAmount);
        
        // Update tracking
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
        
        // Calculate DEMI to send
        uint256 demiAmount = calculateTokenAmount(usdcAmount);
        require(demiAmount <= balanceOf(address(this)), "Insufficient DEMI in contract");
        
        // Transfer USDC from buyer to this contract
        require(
            USDC.transferFrom(msg.sender, address(this), usdcAmount),
            "USDC transfer failed"
        );
        
        // Transfer DEMI to buyer
        _transfer(address(this), msg.sender, demiAmount);
        
        // Update tracking
        totalSold += demiAmount;
        totalRaisedUSDC += usdcAmount;
        
        emit TokensPurchased(msg.sender, demiAmount, usdcAmount, address(USDC));
    }
    
    // ========== OWNER FUNCTIONS ==========
    
    /**
     * @notice Withdraw all USDT from contract
     * @dev Only owner can call this
     */
    function withdrawUSDT() external onlyOwner {
        uint256 balance = USDT.balanceOf(address(this));
        require(balance > 0, "No USDT to withdraw");
        require(USDT.transfer(owner(), balance), "USDT transfer failed");
        
        emit FundsWithdrawn(address(USDT), balance);
    }
    
    /**
     * @notice Withdraw all USDC from contract
     * @dev Only owner can call this
     */
    function withdrawUSDC() external onlyOwner {
        uint256 balance = USDC.balanceOf(address(this));
        require(balance > 0, "No USDC to withdraw");
        require(USDC.transfer(owner(), balance), "USDC transfer failed");
        
        emit FundsWithdrawn(address(USDC), balance);
    }
    
    /**
     * @notice Withdraw unsold DEMI tokens
     * @dev Only owner can call this - useful after sale ends
     */
    function withdrawUnsoldTokens() external onlyOwner {
        uint256 balance = balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        _transfer(address(this), owner(), balance);
    }
    
    /**
     * @notice Update token price
     * @param newPrice New price in USD (6 decimals)
     * @dev Only owner can call this
     */
    function setTokenPrice(uint256 newPrice) external onlyOwner {
        require(newPrice > 0, "Price must be greater than 0");
        uint256 oldPrice = tokenPrice;
        tokenPrice = newPrice;
        
        emit PriceUpdated(oldPrice, newPrice);
    }
    
    /**
     * @notice Enable or disable sale
     * @param _active True to enable, false to disable
     * @dev Only owner can call this
     */
    function setSaleActive(bool _active) external onlyOwner {
        saleActive = _active;
        emit SaleStatusChanged(_active);
    }
    
    // ========== VIEW FUNCTIONS ==========
    
    /**
     * @notice Get current sale statistics
     * @return currentPrice Current token price
     * @return tokensSold Total tokens sold
     * @return raisedUSDT Total USDT raised
     * @return raisedUSDC Total USDC raised
     * @return remainingTokens Tokens remaining in contract
     * @return isActive Whether sale is active
     */
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
    
    /**
     * @notice Get contract balance of payment tokens
     * @return usdtBalance USDT balance in contract
     * @return usdcBalance USDC balance in contract
     */
    function getContractBalances() external view returns (
        uint256 usdtBalance,
        uint256 usdcBalance
    ) {
        return (
            USDT.balanceOf(address(this)),
            USDC.balanceOf(address(this))
        );
    }
}
