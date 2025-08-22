;; Title: BitBridge Commerce Core
;; Summary: A Bitcoin-native, enterprise-grade smart contract for seamless sBTC payment routing, settlement automation, 
;; and dynamic business integration on Stacks.
;;
;; Description:
;; BitBridge Commerce Core is a Bitcoin Layer-2 financial infrastructure component built for modern commerce. 
;; Tailored for enterprises and merchant platforms, it facilitates secure and automated sBTC payments on the Stacks blockchain.
;; Features include programmable multi-party fee distribution, automated invoicing, real-time fund settlement, and advanced 
;; merchant account lifecycle management. With built-in refund logic, reference-based invoice mapping, webhook support, and 
;; balance segregation, BitBridge ensures reliable, transparent, and extensible payment workflows for regulated and global commerce.

;; Constants

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_PAYMENT_NOT_FOUND (err u102))
(define-constant ERR_PAYMENT_ALREADY_PROCESSED (err u103))
(define-constant ERR_PAYMENT_EXPIRED (err u104))
(define-constant ERR_INSUFFICIENT_BALANCE (err u105))
(define-constant ERR_BUSINESS_NOT_REGISTERED (err u106))
(define-constant ERR_INVALID_SIGNATURE (err u107))

;; Data Variables

(define-data-var next-payment-id uint u1)
(define-data-var platform-fee-basis-points uint u100) ;; Default 1%
(define-data-var fee-collector principal CONTRACT_OWNER)

;; Data Maps

(define-map businesses
  principal
  {
    name: (string-ascii 64),
    webhook-url: (optional (string-ascii 256)),
    fee-rate: uint, ;; in basis points (1% = 100)
    is-active: bool,
    total-processed: uint,
    registration-block: uint,
  }
)

(define-map payments
  uint
  {
    business: principal,
    customer: (optional principal),
    amount: uint,
    description: (string-ascii 256),
    reference-id: (string-ascii 64),
    status: (string-ascii 16), ;; "pending", "completed", "expired", "refunded"
    created-at: uint,
    expires-at: uint,
    processed-at: (optional uint),
    processor: (optional principal),
  }
)

(define-map payment-references
  {
    business: principal,
    reference: (string-ascii 64),
  }
  uint
)

(define-map business-balances
  principal
  uint
)

;; Public Functions

;; Registers a new business account with optional webhook for notifications.
(define-public (register-business
    (name (string-ascii 64))
    (webhook-url (optional (string-ascii 256)))
  )
  (let ((caller tx-sender))
    (asserts! (is-none (map-get? businesses caller)) ERR_UNAUTHORIZED)
    (asserts! (> (len name) u0) ERR_INVALID_AMOUNT)
    (asserts! (<= (len name) u64) ERR_INVALID_AMOUNT)
    (map-set businesses caller {
      name: name,
      webhook-url: webhook-url,
      fee-rate: u0,
      is-active: true,
      total-processed: u0,
      registration-block: stacks-block-height,
    })
    (ok true)
  )
)