# 🎁 Gift Card Management Platform

A SQL-only backend implementation of a full-featured Gift Card Management System. This project demonstrates advanced database design and logic using MySQL, including stored procedures, triggers, fraud detection mechanisms, and reporting views.

---

## 📘 Project Overview

The **Gift Card Management Platform** is designed to manage and track the lifecycle of gift cards, including creation, redemption, recharging, transfers, and fraud detection.

**Key Objectives:**
- Enable gift card operations with validation
- Ensure data integrity and balance accuracy
- Implement fraud monitoring logic
- Provide insightful reports using views

---

## 🗃️ Database Schema Design

The schema is built around 5 core tables:

| Table Name            | Purpose                                                        |
|-----------------------|----------------------------------------------------------------|
| `users`               | Stores user/customer data                                      |
| `gift_cards`          | Holds card info (balance, status, assignment)                 |
| `transactions`        | Logs recharge and redemption history                           |
| `gift_card_transfers` | Tracks card ownership changes (bonus feature)                  |
| `fraud_logs`          | Records suspicious activities for auditing and analysis        |

An ER diagram is included in the full documentation (PDF).

---

## 📋 Table Summary

- **`users`**: Basic user info, contact, and account creation date.
- **`gift_cards`**: Card code, balance, status, expiry, user association.
- **`transactions`**: Amounts and types of transactions (recharge/redeem).
- **`gift_card_transfers`**: Transfer history with from/to user IDs and reasons.
- **`fraud_logs`**: Logs suspicious events like rapid usage or high recharges.

---

## ⚙️ Stored Procedures

| Procedure Name               | Description                                                 |
|-----------------------------|-------------------------------------------------------------|
| `generate_gift_card`        | Creates a new gift card with balance and expiry             |
| `redeem_gift_card`          | Redeems balance from an active card                         |
| `recharge_gift_card`        | Adds funds to a valid card                                  |
| `transfer_gift_card`        | Transfers card between users                                |
| `bulk_generate_gift_cards`  | Creates multiple cards with looped logic                    |

---

## 🚨 Triggers & Events

| Trigger Name                          | Purpose                                                       |
|--------------------------------------|---------------------------------------------------------------|
| `before_card_insert_check_balance`   | Prevents negative balance at creation                         |
| `before_card_update_block_if_expired`| Prevents updates on expired cards                             |
| `after_transaction_insert_check_balance` | Ensures post-transaction balance is non-negative          |
| `before_transaction_redeem_only_if_active` | Allows redemptions only for active cards              |
| `after_transfer_log_to_fraud_if_too_fast` | Logs quick successive transfers as fraud              |
| `after_redeem_multiple_within_minute`| Flags multiple redemptions in a minute                       |
| `after_recharge_large_amount_log`    | Flags large top-ups for fraud review                         |

---

## 📊 Views & Reports

- `view_total_issued_cards`: Count of all gift cards issued
- `view_total_active_cards`: Count of active cards
- `view_total_expired_cards`: Expired cards summary
- `view_total_redeemed_value`: Total value redeemed
- `view_user_card_summary`: Per-user card count and balance
- `view_transaction_summary_by_type`: Breakdown of transactions by type
- `view_fraud_summary`: Common fraud types and occurrences

---

## ✅ Testing & Verification

**Tested Scenarios:**
- Valid/invalid card creation
- Card redemption under various conditions
- Recharge and auto-expiry logic
- Trigger validation and fraud detection simulation
- Bulk card generation and reporting accuracy

> All test cases passed. Data integrity is maintained. System is ready for frontend integration.

---

## 🧾 Final Checklist

| Feature                             | Status     |
|------------------------------------|------------|
| Gift Card Creation                 | ✅ Yes      |
| Redemption / Recharge              | ✅ Yes      |
| Balance Tracking                   | ✅ Yes      |
| Expiry Handling via Events         | ✅ Yes      |
| Gift Card Transfers                | ✅ Yes      |
| Bulk Generation                    | ✅ Yes      |
| Fraud Detection                    | ✅ Yes      |
| Validation via Triggers            | ✅ Yes      |
| Report Generation (Views)          | ✅ Yes      |
| Testing & Verification             | ✅ Yes      |

---

## 📦 Tech Stack

- **Database**: MySQL 9.3.0
- **Tools**: MySQL Workbench
- **Languages**: SQL (procedures, triggers, events, views)

---

## 📌 Submission Details

- **Project Title**: Gift Card Management Platform  
- **Submitted By**: Gyan Gupta  
- **Email**: gyangupta6645@gmail.com  
- **Contact**: +91-9421133872  
- **Institution**: MIT-WPU (PUNE)  
- **Program**: M.Sc Data Science and Big Data Analytics  
- **Passing Year**: 2026  

---

## 📁 Repository Structure

```bash
Gift_Card_Management/
│
├── schema.sql                # Table creation scripts
├── procedures.sql            # All stored procedures
├── triggers.sql              # All trigger definitions
├── events.sql                # Event for auto-expiry
├── views.sql                 # Reporting views
├── test_cases.sql            # Sample test data and testing cases
├── README.md                 # This file
└── Gift_Card_Management_Documentation.pdf  # Full documentation
