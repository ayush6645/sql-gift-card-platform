SHOW TABLES;
DESCRIBE users;
DESCRIBE gift_cards;
DESCRIBE transactions;
DESCRIBE gift_card_transfers;
DESCRIBE fraud_logs;

---------------------------- CHECK TABLES -----------------------------------------
-- Users
SELECT * FROM users;

-- Gift Cards (linked and unlinked)
SELECT * FROM gift_cards;

-- Transactions
SELECT * FROM transactions;

-- Transfers
SELECT * FROM gift_card_transfers;

-- Fraud logs
SELECT * FROM fraud_logs;




-------------------------- TEST PROCEDURE ------------------------


-- 1. Generate a new card
CALL generate_gift_card('GC20240620X', 1000.00, '2025-12-31', 1);

-- 2. Redeem an amount
CALL redeem_gift_card('GC20240620X', 200.00);

-- 3. Recharge the card
CALL recharge_gift_card('GC20240620X', 500.00);

-- 4. Transfer the card to another user
CALL transfer_gift_card('GC20240620X', 1, 2, 'Transferred for gift purpose');



-------------- TEST TRIGGERS  -------------


-- Redeem a normal amount (should update balance and insert transaction)
CALL redeem_gift_card('GC20240620X', 50.00);

-- Redeem amount exceeding balance (should error or log fraud)
CALL redeem_gift_card('GC20240620X', 1000000.00);

-- Redeem repeatedly fast (simulate rapid redemption)
CALL redeem_gift_card('GC20240620X', 5.00);
CALL redeem_gift_card('GC20240620X', 5.00);
CALL redeem_gift_card('GC20240620X', 5.00);


----- CHECK ------
SELECT * FROM fraud_logs ORDER BY log_time DESC LIMIT 5;
SELECT current_balance FROM gift_cards WHERE card_code = 'GC20240620X';
SELECT * FROM transactions WHERE card_id = (SELECT card_id FROM gift_cards WHERE card_code='GC20240620X');


----------------------- TRIGGERS ON RECHARGE TRANSACTION ----------------------
CALL recharge_gift_card('GC20240620X', 100.00);


SELECT current_balance FROM gift_cards WHERE card_code = 'GC20240620X';
SELECT * FROM transactions WHERE txn_type = 'recharge' ORDER BY txn_date DESC LIMIT 3;


---------------- TRIGGERS ON TRANSFER GIFT CARD ------------------------

CALL transfer_gift_card('GC20240620X', 1, 2, 'Testing transfer trigger');

SELECT * FROM gift_card_transfers WHERE card_id = (SELECT card_id FROM gift_cards WHERE card_code='GC20240620X') ORDER BY transfer_date DESC LIMIT 3;
SELECT user_id FROM gift_cards WHERE card_code = 'GC20240620X';


----------- Trigger on Insert/Update for Fraud Detection --------------------- 
SELECT * FROM fraud_logs ORDER BY log_time DESC LIMIT 5;


 



