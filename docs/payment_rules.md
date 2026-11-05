# Masrah Payment Gateway Rules & Validation Requirements

**Document Version:** 2.1
**Prepared by:** Masrah Product Team & NexusWave Architecture Board
**Context:** This document outlines the explicit business rules, fee structures, and validation requirements for all payment methods supported by Masrah. 

> **Architecture Note for NexusWave Developers:** 
> As part of the V2 refactoring, these rules **must not** be evaluated inside UI components (Widgets). You must encapsulate these calculations and validations within your Domain layer Use Cases and instantiate the appropriate payment processor using a **Factory Method** pattern based on the selected payment type.

---

## 1. Credit Card (Visa / Mastercard)
Used for direct, real-time ticket purchases via our banking partner (CIB/Paymob).

### 1.1 Transaction Fees
* **Variable Fee:** 2.5% of the base ticket price.
* **Fixed Fee:** 2.00 EGP per transaction.
* **Calculation:** `Total = Ticket Price + (Ticket Price * 0.025) + 2.00`

### 1.2 Validation Requirements
* **Card Number:** Must be exactly 16 digits and pass the Luhn algorithm check.
* **Expiry Date:** Must be in `MM/YY` format and cannot be in the past.
* **CVV:** Must be exactly 3 digits.

### 1.3 Business Rules
* Requires immediate capture.
* Must return a `redirect_url` for 3D Secure (OTP) bank authentication. 
* Max transaction limit: 20,000 EGP.

---

## 2. Fawry (Retail Kiosk / Cash Collection)
Fawry is Egypt's leading cash collection network. Users select this to pay in cash at a local kiosk.

### 2.1 Transaction Fees
Fawry uses a tiered fixed-fee structure based on the ticket price:
* **Tier 1 (Under 500 EGP):** Flat 5.00 EGP fee.
* **Tier 2 (500 EGP to 1,999 EGP):** Flat 10.00 EGP fee.
* **Tier 3 (2,000 EGP and above):** Flat 25.00 EGP fee.

### 2.2 Validation Requirements
* **Mobile Number:** Must be a valid 11-digit Egyptian mobile number (Starts with `010`, `011`, `012`, or `015`).
* **Email:** Standard email format validation required for sending the receipt.

### 2.3 Business Rules
* Payment is asynchronous.
* The API returns a 9-digit `fawry_reference_code`.
* The ticket entity must be set to `TicketStatus.pending`.
* The code expires in exactly 24 hours. If not paid by then, the reserved seat is released back to the event pool.

---

## 3. Vodafone Cash (Mobile Wallet)
Egypt's most popular mobile money wallet, requiring a Vodafone network number.

### 3.1 Transaction Fees
* **Variable Fee:** 1.0% of the base ticket price.
* **Fee Cap:** The fee cannot exceed 20.00 EGP, regardless of the ticket price.
* **Calculation:** `Fee = MIN((Ticket Price * 0.01), 20.00 EGP)`

### 3.2 Validation Requirements
* **Mobile Number:** Must be exactly 11 digits and **MUST** start with `010` (Vodafone Egypt prefix). Any other prefix (`011`, `012`, `015`) must throw an `InvalidWalletProviderException`.

### 3.3 Business Rules
* The user will receive an SMS push on their phone containing a PIN prompt.
* The application must poll the backend transaction status endpoint every 5 seconds until it returns `success` or `failed`.
* Max transaction limit: 10,000 EGP (Central Bank of Egypt mobile wallet limit).

---

## 4. Generic Digital Wallet (Meeza Pay / Apple Pay)
Used for NFC or tokenized card payments.

### 4.1 Transaction Fees
* **Variable Fee:** Flat 1.5% fee on the ticket base price.
* **Calculation:** `Total = Ticket Price + (Ticket Price * 0.015)`

### 4.2 Validation Requirements
* **Device Token / Wallet ID:** Must not be null or empty.
* **QR Code (Meeza):** If Meeza is selected, the wallet ID must be alphanumeric and exactly 24 characters long.

### 4.3 Business Rules
* Immediate capture and fulfillment.
* Limit of 5,000 EGP per transaction to comply with rapid-tap CBE limits.

---

## Global Validation Rules

Regardless of the payment method constructed by the Factory, the following rules apply to ALL booking requests:

1. **VAT:** An Egyptian Value Added Tax (VAT) of 14% is applied to the **base ticket price** (calculated before payment gateway fees).
2. **Seat Availability:** The selected `seat_id` must be locked via the Domain layer before the payment processor is invoked.
3. **Currency Constraint:** All calculations must be performed and rounded to two decimal places (PT / Piastres). No fractional piastres are allowed in the final payload.