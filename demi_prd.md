# Product Requirements Document (PRD)
# Demi Token Launch Platform

## Version 1.0
**Date:** January 2025  
**Project:** Demi Token Launch Platform  
**Document Type:** Technical PRD for Development Team

---

## Executive Summary

The Demi Token Launch Platform is a decentralized token sale interface enabling users to purchase $DEMI tokens during the Initial Coin Offering (ICO) phase. Built on the Polygon network for optimal speed and efficiency, the platform facilitates token purchases using USDC/USDT stablecoins through an intuitive bridge interface.

### Key Features
- Token sale mechanism with progressive pricing tiers
- Multi-wallet integration (MetaMask, Coinbase Wallet, WalletConnect)
- Real-time balance display and transaction tracking
- Automated whitepaper distribution
- Interactive DEX+ information page with live-typing animation

Note: For the colour code of this project, we will focus on white, blacks, blue hues, for the blue, specifically: #0437F2
---

## 1. Platform Architecture Overview

### 1.1 Technology Stack

**Frontend:**
- Framework: React.js / Next.js (recommended for SEO and performance)
- Styling: Tailwind CSS or styled-components
- State Management: Redux or Zustand
- Web3 Integration: ethers.js or web3.js
- Wallet Connection: WalletConnect, Web3Modal

**Backend:**
- Node.js with Express.js
- WebSocket for real-time updates
- Database: PostgreSQL for transaction records
- Redis for caching and session management

**Blockchain:**
- Network: Polygon (MATIC)
- Token Standard: ERC-20 for $DEMI
- Smart Contracts: Solidity
- Integration: Web3 libraries for blockchain interaction

### 1.2 System Architecture Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Frontend      │────▶│   Backend API   │────▶│  Smart Contract │
│  (React/Next)   │     │   (Node.js)     │     │   (Polygon)     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                        │
         │                       │                        │
         ▼                       ▼                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Wallet APIs    │     │   Database      │     │   Token Sale    │
│  (MetaMask,     │     │  (PostgreSQL)   │     │   Contract      │
│   Coinbase,     │     └─────────────────┘     └─────────────────┘
│  WalletConnect) │
└─────────────────┘
```

---

## 2. User Interface Specifications

### 2.1 Header Navigation

**Logo Section:**
- Text: "demi" (using font Bodoni FLF)
- logo image by the side
- Position: Top-left corner

**Navigation Tabs:**
1. **Token Launch** (Default active tab)
2. **Whitepaper** (Triggers PDF download on click)
3. **Dex+** (Routes to animated explanation page)

**Wallet Connection:**
- Position: Top-right corner
- Button text: "Connect wallet"
- State changes: Shows wallet address when connected

### 2.2 Token Launch Page (Main Interface)

#### Section 1: Page Title
- Display: "$demi" (replacing "Bridge" from reference)
- Styling: Large, centered heading
- Font: Bold, prominent display

#### Section 2: Token Exchange Interface

**Labels:**
- "Receive" (left side, replacing "Source")
- "Send" (right side, replacing "Destination")

**Receive Side (Left):**
- Token: Demi (fixed, no dropdown)
- Display: Demi logo + "DEMI" text
- Input field: Amount to receive
- Calculation: Auto-calculated based on send amount and current price

**Send Side (Right):**
- Default Token: USDC
- Display: USDC logo + "USDC" text
- Dropdown Options:
  - USDC (default)
  - USDT
- Input field: Amount to send
- Real-time conversion display

**Exchange Arrow:**
- Bidirectional arrow between Receive and Send sections
- Non-clickable (no swap functionality needed)

#### Section 3: Price Tier Display

**Layout:** Single horizontal line containing:
- **Label:** "Price: $0.01"
- **Progress Bar:** 
  - Contains countdown timer: " [countdown to Nov 2, 12:00 AM GMT]"
  - Arrow indicator pointing to: "$0.02"
  - Visual progress indicator showing time remaining

**Functionality:**
- Real-time countdown updating every second
- Auto-refresh when tier changes
- Price update triggers recalculation of token amounts

#### Section 4: Transaction Details

**Balance Display:**
- Label: "Balance: [amount] [USDC/USDT]"
- Visibility: Only shows when wallet is connected
- Updates: Real-time based on selected token (USDC/USDT)
- Format: "Balance: 1,234.56 USDC"

**Send Amount:**
- Input field with selected token logo
- Placeholder: "0.00"
- Validation: Numeric only, max decimals based on token

**Receive Amount:**
- Display field (read-only)
- Auto-calculated: sendAmount / currentPrice
- Format: "0.00 DEMI"

#### Section 5: Payment Instructions

**DEMI Wallet Address:**
- Label: "DEMI Address"
- Display: Full wallet address ( "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7")
- Copy Icon: Clipboard copy functionality

**Copy Icon Behavior:**
- On click: Opens modal/popup with detailed instructions
- Modal content:

```
How to Send [USDC/USDT] to Purchase DEMI Tokens:

Step 1: Copy the DEMI wallet address
[0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7] [Copy Button]

Step 2: Send [USDC/USDT] from your wallet
- Open your crypto wallet
- Select "Send" and choose [USDC/USDT]
- Paste the DEMI address and enter the amount
- Confirm the transaction

Your DEMI tokens will be allocated after confirmation.
```

**Estimated Transfer Time:**
- Display: "Estimated time for transfer: About 1 minute"
- Position: Below address section

#### Section 6: Connect Wallet Button

**Initial State:**
- Button text: "Connect Wallet"
- Style: Gradient background (blue to white)
- Full width button

**Connected State:**
- Display: Truncated wallet address (e.g., "0x742d...bEb7")
- Dropdown option to disconnect

---

## 3. Wallet Connection Modal

### 3.1 Modal Structure

**Title:** "Connect Wallet"
**Close Button:** X icon in top-right corner

### 3.2 Wallet Options

Display only three wallet options:

1. **MetaMask**
   - Logo + "MetaMask" text
   - Connect button/state indicator

2. **Coinbase Wallet**
   - Logo + "Coinbase" text
   - Connect button/state indicator

3. **WalletConnect**
   - Logo + "WalletConnect" text
   - Connect button/state indicator

### 3.3 Alternative Instructions

Below wallet options:
```
Don't see your wallet?

You can manually send USDC or USDT to purchase DEMI tokens:

Step 1: Copy this address:
[0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7] [Copy]

Step 2: Send USDC or USDT from any wallet to the address above

Your tokens will be allocated after transaction confirmation.
```

---

## 4. Whitepaper Page

### Functionality
- **Trigger:** Click on "Whitepaper" tab
- **Action:** Immediate PDF download
- **File:** demi_whitepaper.pdf
- **No page navigation:** User stays on current page
- **Implementation:** 
  ```javascript
  const downloadWhitepaper = () => {
    const link = document.createElement('a');
    link.href = '/assets/demi_whitepaper.pdf';
    link.download = 'demi_whitepaper.pdf';
    link.click();
  };
  ```

---

## 5. Dex+ Page Specifications

### 5.1 Page Concept
Interactive, full-screen typing animation explaining the DEMI ecosystem's decentralized exchange features.

### 5.2 Technical Implementation

**Animation Library Options:**
- Typed.js for typing effect
- Custom React hook for more control
- Framer Motion for smooth transitions

**Audio:**
- Keyboard clicking sound effect
- Toggle button for sound on/off
- Volume control slider

### 5.3 Content Script

The following text should appear with typing animation:

```
Welcome to DEMI DEX+

The Future of Decentralized Trading. Our revolutionary decentralized exchange built by ex-Ethereum and ex-Polkadot devs empowers $DEMI holders 
with unprecedented earning potential. Every $DEMI holder automatically earns over 13% APY through our 
innovative staking and liquidity provision mechanisms. Your $DEMI tokens work for you 24/7, generating returns from 
trading fees, liquidity rewards, and our unique profit-sharing model. We are allocating 50%  of our ICO raise Community & Liquidity Pool and 50% to Team & Development Fund. Demi is built on Polygon which aids lightning-fast transactions with minimal fees, ensuring maximum returns for our holders. $DEMI isn't just another token – it's your gateway to sustainable passive income in the DeFi ecosystem.$DEMI will become the world's biggest ICO launch, setting new standards for community-driven finance. Demi Token goes public on Decemeber 2nd.

[End with blinking cursor]
```

### 5.4 Animation Specifications

- **Font Size:** Large (48px-64px on desktop, responsive on mobile)
- **Typing Speed:** 50-80ms per character
- **Line Breaks:** Natural pauses (500ms) between sections
- **Full Screen:** Content takes entire viewport
- **Background:** Dark theme with subtle gradient
- **Text Color:** White with slight glow effect
- **Sound:** Mechanical keyboard clicking (optional)

---

## 6. Backend Requirements

### 6.1 API Endpoints

#### Authentication & Wallet

**POST /api/wallet/connect**
```javascript
Request: {
  walletAddress: string,
  walletType: 'metamask' | 'coinbase' | 'walletconnect',
  signature: string
}
Response: {
  success: boolean,
  sessionToken: string,
  walletData: {
    address: string,
    balance: {
      usdc: number,
      usdt: number
    }
  }
}
```

**GET /api/wallet/balance/:address**
```javascript
Response: {
  address: string,
  balances: {
    usdc: string,
    usdt: string,
    demi: string
  },
  network: 'polygon'
}
```

#### Token Sale

**GET /api/token/price**
```javascript
Response: {
  currentPrice: number, // 0.01
  nextPrice: number, // 0.02
  tierEndTime: timestamp, // Nov 2, 12:00 AM GMT
  currentTier: number,
  tokensSold: number,
  tokensAvailable: number
}
```

**POST /api/token/calculate**
```javascript
Request: {
  sendAmount: number,
  sendToken: 'USDC' | 'USDT',
  currentPrice: number
}
Response: {
  receiveAmount: number, // DEMI tokens
  fee: number,
  estimatedTime: string
}
```

**POST /api/transaction/initiate**
```javascript
Request: {
  walletAddress: string,
  sendAmount: number,
  sendToken: 'USDC' | 'USDT',
  receiveAmount: number,
  transactionHash: string
}
Response: {
  transactionId: string,
  status: 'pending' | 'confirmed' | 'failed',
  estimatedCompletion: timestamp
}
```

### 6.2 WebSocket Events

**Connection:**
```javascript
socket.on('connect', (walletAddress) => {
  // Subscribe to wallet-specific updates
});
```

**Price Updates:**
```javascript
socket.emit('priceUpdate', {
  currentPrice: number,
  nextTierIn: seconds,
  tokensSold: number
});
```

**Balance Updates:**
```javascript
socket.emit('balanceUpdate', {
  walletAddress: string,
  balances: {
    usdc: string,
    usdt: string,
    demi: string
  }
});
```

### 6.3 Smart Contract Integration

**Token Sale Contract Methods:**

```solidity
// Core functions to integrate
function buyTokens(uint256 _usdcAmount) external
function buyTokensWithUSDT(uint256 _usdtAmount) external
function getCurrentPrice() public view returns (uint256)
function getTokenBalance(address _holder) public view returns (uint256)
function getTierEndTime() public view returns (uint256)
```

**Web3 Integration:**
```javascript
const web3 = new Web3(window.ethereum);
const contract = new web3.eth.Contract(TOKEN_SALE_ABI, CONTRACT_ADDRESS);

// Get current price
const currentPrice = await contract.methods.getCurrentPrice().call();

// Buy tokens
await contract.methods.buyTokens(amount).send({ from: userAddress });
```

---

## 7. Database Schema

### 7.1 Tables Structure

**users**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  wallet_address VARCHAR(42) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP,
  total_purchased DECIMAL(20, 8) DEFAULT 0,
  referral_code VARCHAR(20)
);
```

**transactions**
```sql
CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  transaction_hash VARCHAR(66) UNIQUE,
  send_amount DECIMAL(20, 8),
  send_token VARCHAR(10),
  receive_amount DECIMAL(20, 8),
  price_at_purchase DECIMAL(10, 4),
  status VARCHAR(20), -- pending, confirmed, failed
  created_at TIMESTAMP DEFAULT NOW(),
  confirmed_at TIMESTAMP
);
```

**price_tiers**
```sql
CREATE TABLE price_tiers (
  id SERIAL PRIMARY KEY,
  tier_number INTEGER,
  price DECIMAL(10, 4),
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  tokens_available DECIMAL(20, 8),
  tokens_sold DECIMAL(20, 8) DEFAULT 0
);
```

---

## 8. Security Requirements

### 8.1 Frontend Security
- Input validation and sanitization
- XSS protection
- CSRF tokens for forms
- Secure wallet connection handling
- Environment variables for sensitive data

### 8.2 Backend Security
- Rate limiting on all API endpoints
- JWT token authentication
- SQL injection prevention
- Signature verification for wallet connections
- Audit logging for all transactions

### 8.3 Smart Contract Security
- Reentrancy guards
- Integer overflow protection
- Access control modifiers
- Emergency pause functionality
- Multi-signature wallet for admin functions

---

## 9. Deployment Configuration

### 9.1 Environment Variables

**.env.local (Frontend)**
```
NEXT_PUBLIC_API_URL=https://api.demitoken.com
NEXT_PUBLIC_CONTRACT_ADDRESS=0x...
NEXT_PUBLIC_POLYGON_RPC=https://polygon-rpc.com
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=...
```

**.env (Backend)**
```
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
JWT_SECRET=...
POLYGON_RPC_URL=https://...
CONTRACT_PRIVATE_KEY=...
DEMI_WALLET_ADDRESS=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb7
```

### 9.2 Deployment Checklist

- [ ] SSL certificates configured
- [ ] CDN setup for static assets
- [ ] Database migrations completed
- [ ] Redis cache configured
- [ ] Smart contracts deployed and verified
- [ ] API rate limiting configured
- [ ] Monitoring and logging setup
- [ ] Backup systems configured
- [ ] Load testing completed

---

## 10. Testing Requirements

### 10.1 Unit Tests
- Smart contract function tests
- API endpoint tests
- Component rendering tests
- Utility function tests

### 10.2 Integration Tests
- Wallet connection flow
- Token purchase flow
- Price tier transitions
- Balance updates

### 10.3 End-to-End Tests
- Complete user journey from landing to purchase
- Multi-wallet testing
- Cross-browser compatibility
- Mobile responsiveness

---


## Appendix A: Technical Stack Details

### Frontend Dependencies
```json
{
  "dependencies": {
    "react": "^18.2.0",
    "next": "^14.0.0",
    "ethers": "^6.9.0",
    "web3modal": "^3.5.0",
    "@walletconnect/client": "^2.10.0",
    "axios": "^1.6.0",
    "socket.io-client": "^4.5.0",
    "typed.js": "^2.1.0",
    "framer-motion": "^10.16.0",
    "tailwindcss": "^3.4.0",
    "react-hot-toast": "^2.4.0"
  }
}
```

### Backend Dependencies
```json
{
  "dependencies": {
    "express": "^4.18.0",
    "socket.io": "^4.5.0",
    "pg": "^8.11.0",
    "redis": "^4.6.0",
    "ethers": "^6.9.0",
    "jsonwebtoken": "^9.0.0",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "express-rate-limit": "^7.1.0",
    "dotenv": "^16.3.0"
  }
}
```

---

## Appendix B: Error Handling

### Frontend Error States
- Wallet connection failures
- Insufficient balance
- Network mismatch
- Transaction failures
- API timeout

### Error Messages
```javascript
const ERROR_MESSAGES = {
  WALLET_NOT_CONNECTED: "Please connect your wallet to continue",
  INSUFFICIENT_BALANCE: "Insufficient balance for this transaction",
  NETWORK_MISMATCH: "Please switch to Polygon network",
  TRANSACTION_FAILED: "Transaction failed. Please try again",
  API_ERROR: "Service temporarily unavailable",
  MIN_PURCHASE: "Minimum purchase amount is 10 USDC",
  MAX_PURCHASE: "Maximum purchase amount is 100,000 USDC"
};
```

---

## Appendix C: Component Structure

### React Component Hierarchy
```
App
├── Layout
│   ├── Header
│   │   ├── Logo
│   │   ├── Navigation
│   │   └── WalletButton
│   └── Footer
├── Pages
│   ├── TokenLaunch
│   │   ├── ExchangeInterface
│   │   ├── PriceTier
│   │   ├── TransactionDetails
│   │   └── PaymentInstructions
│   ├── Whitepaper
│   └── DexPlus
│       └── TypewriterAnimation
└── Modals
    ├── WalletModal
    └── InstructionsModal
```

---

## Document Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | January 2025 | Development Team | Initial PRD creation |

---

## Contact & Support

For technical questions or clarifications regarding this PRD:
- Technical Lead: [Contact Information]
- Project Manager: [Contact Information]
- Smart Contract Developer: [Contact Information]

---

**END OF DOCUMENT**
