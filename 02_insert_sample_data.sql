USE gift_card_platform;

-- Insert sample users
INSERT INTO users (username, email, phone, address) VALUES
('Alice Johnson', 'alice@example.com', '1234567890', '123 Maple St, Springfield'),
('Bob Smith', 'bob@example.com', '0987654321', '456 Oak Ave, Shelbyville'),
('Carol Lee', 'carol@example.com', '5555555555', '789 Pine Rd, Capital City');

-- Insert sample gift cards (some assigned, some unassigned)
INSERT INTO gift_cards (card_code, initial_balance, current_balance, expiration_date, status, user_id, assigned_at) VALUES
('GC20250619A', 100.00, 100.00, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'active', 1, NOW()),
('GC20250619B', 50.00, 50.00, DATE_ADD(CURDATE(), INTERVAL 60 DAY), 'active', 2, NOW()),
('GC20250619C', 200.00, 150.00, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'active', 1, NOW()),
('GC20250619D', 75.00, 75.00, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'inactive', NULL, NULL),
('GC20250619E', 150.00, 150.00, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'blocked', NULL, NULL),
('GC20250619F', 120.00, 0.00, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'expired', 3, NOW());

-- Insert sample transactions (redeem, partial_redeem, recharge)
INSERT INTO transactions (card_id, txn_type, amount, description) VALUES
(1, 'redeem', 20.00, 'Redeemed for order #1001'),
(1, 'partial_redeem', 30.00, 'Partial redemption for order #1002'),
(1, 'recharge', 50.00, 'Recharged with promo credit'),
(2, 'redeem', 25.00, 'Redeemed for order #1003'),
(3, 'redeem', 50.00, 'Redeemed for order #1004'),
(3, 'partial_redeem', 0.00, 'No amount redeemed - test case'),
(4, 'recharge', 25.00, 'Recharge for inactive card'),
(6, 'redeem', 120.00, 'Redeemed fully before expiry');

-- Insert sample gift card transfers (bonus feature)
INSERT INTO gift_card_transfers (card_id, from_user_id, to_user_id, transfer_reason) VALUES
(1, 1, 2, 'Gift card transfer for birthday'),
(3, 1, 3, 'Transfer due to user request');

-- Insert sample fraud logs (bonus feature)
INSERT INTO fraud_logs (card_id, user_id, event_type, event_description) VALUES
(1, 1, 'suspicious_redeem', 'Multiple redemptions in a short time'),
(2, 2, 'rapid_redeem', 'Redeemed twice within 1 minute'),
(5, NULL, 'multiple_failed_attempts', 'Several invalid redemption attempts');

