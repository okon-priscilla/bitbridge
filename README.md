# BitBridge Commerce Core

A Bitcoin-native, enterprise-grade smart contract for seamless sBTC payment routing, settlement automation, and dynamic business integration on Stacks.

## Overview

BitBridge Commerce Core is a Bitcoin Layer-2 financial infrastructure component built for modern commerce. Tailored for enterprises and merchant platforms, it facilitates secure and automated sBTC payments on the Stacks blockchain. The contract features programmable multi-party fee distribution, automated invoicing, real-time fund settlement, and advanced merchant account lifecycle management.

## Features

- **🏪 Business Registration**: Comprehensive merchant onboarding with customizable fee structures
- **📋 Invoice Management**: Create time-limited payment requests with unique reference IDs
- **💰 Automated Settlement**: Real-time fund distribution with platform and merchant fees
- **🔄 Refund System**: Built-in refund logic for completed payments
- **⚖️ Balance Management**: Segregated merchant balances with withdrawal controls
- **🔗 Reference Mapping**: Invoice tracking via business-specific reference IDs
- **🎯 Webhook Support**: Optional webhook URLs for payment notifications
- **🛡️ Security**: Role-based access control and comprehensive validation

## Architecture

### Core Components

#### Data Maps

- **`businesses`**: Merchant registration and configuration data
- **`payments`**: Complete payment lifecycle tracking
- **`payment-references`**: Reference ID to payment ID mapping
- **`business-balances`**: Segregated merchant fund balances

#### Key Functions

**Business Management**

- `register-business`: Register new merchant accounts
- `update-business`: Modify merchant settings and fee rates

**Payment Processing**

- `create-payment`: Generate invoices with expiration
- `pay-invoice`: Process customer payments with fee distribution
- `refund-payment`: Handle merchant-initiated refunds

**Fund Management**

- `withdraw-balance`: Merchant balance withdrawals
- `get-business-balance`: Query available funds

**Administration**

- `set-platform-fee`: Update global platform fees
- `set-fee-collector`: Modify fee collection address

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) for local development
- Node.js and npm for testing
- Basic understanding of Stacks blockchain and Clarity

### Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd bitbridge
```

2. Install dependencies:

```bash
npm install
```

3. Run tests:

```bash
npm run test
```

### Development Workflow

The project uses Clarinet for contract development:

- **Contract file**: `contracts/bitbridge.clar`
- **Configuration**: `Clarinet.toml`

## Usage Examples

### Business Registration

```clarity
;; Register a new business
(contract-call? .bitbridge register-business
  "My Coffee Shop"
  (some "https://mycoffeeshop.com/webhook"))
```

### Creating Payment Invoices

```clarity
;; Create a payment request for 100 sBTC (in satoshis)
(contract-call? .bitbridge create-payment
  u10000000000  ;; 100 sBTC
  "Coffee and pastry order #12345"
  "order-12345"
  u144)  ;; Expires in ~24 hours
```

### Processing Payments

```clarity
;; Customer pays invoice
(contract-call? .bitbridge pay-invoice u1)
```

### Merchant Operations

```clarity
;; Check balance
(contract-call? .bitbridge get-business-balance tx-sender)

;; Withdraw funds
(contract-call? .bitbridge withdraw-balance u5000000000)  ;; 50 sBTC

;; Process refund
(contract-call? .bitbridge refund-payment u1)
```

## Fee Structure

The contract implements a dual-fee system:

- **Platform Fee**: Global fee set by contract owner (default: 1%)
- **Business Fee**: Per-merchant fee (configurable, max: 10%)

Fees are calculated in basis points (1% = 100 basis points) and automatically deducted during payment processing.

### Fee Calculation

```clarity
;; Calculate fees for a payment amount
(contract-call? .bitbridge calculate-fees
  u10000000000  ;; 100 sBTC
  u250)         ;; 2.5% business fee rate
```

## API Reference

### Public Functions

#### Business Management

##### `register-business`

Registers a new business account with optional webhook for notifications.

**Parameters:**

- `name`: Business name (max 64 characters)
- `webhook-url`: Optional webhook URL for payment notifications (max 256 characters)

**Returns:** `(response bool uint)`

##### `update-business`

Updates an existing business profile, including fee settings and webhook URL.

**Parameters:**

- `name`: Updated business name
- `webhook-url`: Updated webhook URL
- `fee-rate`: Business fee rate in basis points (max 1000 = 10%)

**Returns:** `(response bool uint)`

#### Payment Processing

##### `create-payment`

Initiates a payment request (invoice) with expiration and unique reference ID.

**Parameters:**

- `amount`: Payment amount in sBTC satoshis
- `description`: Payment description (max 256 characters)
- `reference-id`: Unique reference ID (max 64 characters)
- `expires-in-blocks`: Expiration time in blocks (max 4320 ≈ 30 days)

**Returns:** `(response uint uint)` - Payment ID on success

##### `pay-invoice`

Customer pays a pending invoice; platform & merchant fees are handled automatically.

**Parameters:**

- `payment-id`: The payment ID to process

**Returns:** `(response {payment-id: uint, net-amount: uint, fees: uint} uint)`

##### `refund-payment`

Allows a business to refund a previously completed payment.

**Parameters:**

- `payment-id`: The payment ID to refund

**Returns:** `(response uint uint)` - Refund amount on success

#### Fund Management

##### `withdraw-balance`

Merchant withdraws their available balance.

**Parameters:**

- `amount`: Amount to withdraw in sBTC satoshis

**Returns:** `(response uint uint)`

#### Administration

##### `set-platform-fee`

Admin-only: Updates global platform fee.

**Parameters:**

- `new-fee-basis-points`: New platform fee in basis points (max 1000 = 10%)

**Returns:** `(response bool uint)`

##### `set-fee-collector`

Admin-only: Updates address that receives platform fees.

**Parameters:**

- `new-collector`: New fee collector principal

**Returns:** `(response bool uint)`

### Read-Only Functions

#### `get-payment`

Retrieves payment details by payment ID.

**Parameters:**

- `payment-id`: Payment ID to query

**Returns:** `(optional payment-data)`

#### `get-payment-by-reference`

Retrieves payment details by business and reference ID.

**Parameters:**

- `business`: Business principal
- `reference`: Reference ID string

**Returns:** `(optional payment-data)`

#### `get-business`

Retrieves business registration details.

**Parameters:**

- `business-principal`: Business principal to query

**Returns:** `(optional business-data)`

#### `get-business-balance`

Retrieves current balance for a business.

**Parameters:**

- `business-principal`: Business principal to query

**Returns:** `uint` - Current balance in sBTC satoshis

#### `calculate-fees`

Calculates platform and business fees for a given amount.

**Parameters:**

- `amount`: Payment amount
- `business-fee-rate`: Business fee rate in basis points

**Returns:** `{platform-fee: uint, business-fee: uint, total-fees: uint, net-amount: uint}`

#### `is-payment-valid`

Checks if a payment is valid and not expired.

**Parameters:**

- `payment-id`: Payment ID to check

**Returns:** `bool`

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | `ERR_UNAUTHORIZED` | Unauthorized access attempt |
| 101 | `ERR_INVALID_AMOUNT` | Invalid amount or parameter |
| 102 | `ERR_PAYMENT_NOT_FOUND` | Payment does not exist |
| 103 | `ERR_PAYMENT_ALREADY_PROCESSED` | Payment already completed/refunded |
| 104 | `ERR_PAYMENT_EXPIRED` | Payment has expired |
| 105 | `ERR_INSUFFICIENT_BALANCE` | Insufficient balance for operation |
| 106 | `ERR_BUSINESS_NOT_REGISTERED` | Business not registered |
| 107 | `ERR_INVALID_SIGNATURE` | Invalid signature (reserved) |

## Security Considerations

- **Access Control**: Owner-only functions for platform configuration
- **Validation**: Comprehensive input validation and bounds checking
- **Reentrancy**: Protection against reentrancy attacks through proper state management
- **Balance Segregation**: Isolated merchant funds prevent cross-contamination
- **Expiration**: Time-limited payment requests prevent indefinite pending states
- **Fee Limits**: Maximum fee rates prevent excessive charges

## Data Structures

### Business Data

```clarity
{
  name: (string-ascii 64),
  webhook-url: (optional (string-ascii 256)),
  fee-rate: uint,              ;; in basis points
  is-active: bool,
  total-processed: uint,       ;; lifetime processing volume
  registration-block: uint,    ;; registration timestamp
}
```

### Payment Data

```clarity
{
  business: principal,
  customer: (optional principal),
  amount: uint,
  description: (string-ascii 256),
  reference-id: (string-ascii 64),
  status: (string-ascii 16),   ;; "pending", "completed", "expired", "refunded"
  created-at: uint,
  expires-at: uint,
  processed-at: (optional uint),
  processor: (optional principal),
}
```

## Integration Guide

### For Merchants

1. **Register your business**:

   ```clarity
   (contract-call? .bitbridge register-business
     "Your Business Name"
     (some "https://yoursite.com/webhook"))
   ```

2. **Create payment invoices**:

   ```clarity
   (contract-call? .bitbridge create-payment
     amount description reference-id expires-in-blocks)
   ```

3. **Monitor payments and withdraw funds**:

   ```clarity
   ;; Check balance
   (contract-call? .bitbridge get-business-balance tx-sender)
   
   ;; Withdraw
   (contract-call? .bitbridge withdraw-balance amount)
   ```

### For Customers

1. **Find payment by reference**:

   ```clarity
   (contract-call? .bitbridge get-payment-by-reference
     business-principal reference-id)
   ```

2. **Pay invoice**:

   ```clarity
   (contract-call? .bitbridge pay-invoice payment-id)
   ```

### For Platform Operators

1. **Set platform fees**:

   ```clarity
   (contract-call? .bitbridge set-platform-fee new-fee-basis-points)
   ```

2. **Update fee collector**:

   ```clarity
   (contract-call? .bitbridge set-fee-collector new-collector-principal)
   ```

## Testing

Use Clarinet for comprehensive testing:

```bash
# Check contract syntax
clarinet check

# Run contract analysis
clarinet analyze

# Test contract in console
clarinet console
```

## Deployment

### Mainnet Deployment

```bash
clarinet deploy --network mainnet
```

### Testnet Deployment

```bash
clarinet deploy --network testnet
```

## Configuration

The contract uses the following sBTC token contract:

- **Mainnet**: `'ST1F7QA2MDF17S807EPA36TSS8AMEFY4KA9TVGWXT.sbtc-token`

Update the contract reference for different networks as needed.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write comprehensive tests
4. Ensure all checks pass
5. Submit a pull request

## License

This project is open source. See license file for details.

## Support

For issues and questions:

- Open an issue in the repository
- Refer to [Stacks documentation](https://docs.stacks.co/)
- Check [Clarity documentation](https://docs.clarity-lang.org/)
