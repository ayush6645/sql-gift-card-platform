USE gift_card_platform;

-- -----------------------------------------
-- VIEW 1: Total Issued Gift Cards
-- -----------------------------------------
CREATE OR REPLACE VIEW view_total_issued_cards AS
SELECT COUNT(*) AS total_issued_cards
FROM gift_cards;

-- -----------------------------------------
-- VIEW 2: Total Active Gift Cards
-- -----------------------------------------
CREATE OR REPLACE VIEW view_total_active_cards AS
SELECT COUNT(*) AS total_active_cards
FROM gift_cards
WHERE status = 'active';

-- -----------------------------------------
-- VIEW 3: Total Expired Gift Cards
-- -----------------------------------------
CREATE OR REPLACE VIEW view_total_expired_cards AS
SELECT COUNT(*) AS total_expired_cards
FROM gift_cards
WHERE status = 'expired';

-- -----------------------------------------
-- VIEW 4: Total Redeemed Value
-- -----------------------------------------
CREATE OR REPLACE VIEW view_total_redeemed_value AS
SELECT IFNULL(SUM(amount), 0) AS total_redeemed_amount
FROM transactions
WHERE txn_type IN ('redeem', 'partial_redeem');

-- -----------------------------------------
-- VIEW 5: Gift Card Transaction History
-- -----------------------------------------
CREATE OR REPLACE VIEW view_card_transaction_history AS
SELECT 
    gc.card_code,
    t.txn_type,
    t.amount,
    t.description,
    t.txn_date
FROM gift_cards gc
JOIN transactions t ON gc.card_id = t.card_id
ORDER BY gc.card_code, t.txn_date DESC;

-- -----------------------------------------
-- VIEW 6: User-wise Gift Card Summary
-- -----------------------------------------
CREATE OR REPLACE VIEW view_user_card_summary AS
SELECT 
    u.user_id,
    u.username,
    COUNT(gc.card_id) AS total_cards,
    SUM(gc.current_balance) AS total_current_balance,
    SUM(gc.initial_balance) AS total_initial_balance
FROM users u
LEFT JOIN gift_cards gc ON u.user_id = gc.user_id
GROUP BY u.user_id;

-- -----------------------------------------
-- VIEW 7: Fraud Logs Summary
-- -----------------------------------------
CREATE OR REPLACE VIEW view_fraud_logs_summary AS
SELECT 
    fl.log_id,
    u.username,
    gc.card_code,
    fl.event_type,
    fl.event_description,
    fl.log_time
FROM fraud_logs fl
LEFT JOIN users u ON fl.user_id = u.user_id
LEFT JOIN gift_cards gc ON fl.card_id = gc.card_id
ORDER BY fl.log_time DESC;

-- -----------------------------------------
-- VIEW 8: Transfer History
-- -----------------------------------------
CREATE OR REPLACE VIEW view_transfer_history AS
SELECT 
    t.transfer_id,
    gc.card_code,
    u1.username AS from_user,
    u2.username AS to_user,
    t.transfer_reason,
    t.transfer_date
FROM gift_card_transfers t
JOIN gift_cards gc ON t.card_id = gc.card_id
JOIN users u1 ON t.from_user_id = u1.user_id
JOIN users u2 ON t.to_user_id = u2.user_id
ORDER BY t.transfer_date DESC;

-- -----------------------------------------
-- QUERY: Get balance of a specific card
-- -----------------------------------------
-- Example:
-- SELECT * FROM view_card_balance WHERE card_code = 'GC20240619A';

CREATE OR REPLACE VIEW view_card_balance AS
SELECT 
    card_code,
    current_balance,
    status,
    expiration_date
FROM gift_cards;

