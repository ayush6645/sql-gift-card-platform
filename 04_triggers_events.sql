DELIMITER //

CREATE TRIGGER trg_before_transaction_insert
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE v_status ENUM('active', 'inactive', 'blocked', 'expired');

    -- Get the current status of the gift card
    SELECT status INTO v_status
    FROM gift_cards
    WHERE card_id = NEW.card_id;

    -- Check if card status allows transaction
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card does not exist.';
    ELSEIF v_status = 'inactive' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card status is inactive. Transaction not allowed.';
    ELSEIF v_status = 'blocked' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card status is blocked. Transaction not allowed.';
    ELSEIF v_status = 'expired' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card has expired. Transaction not allowed.';
    END IF;
END;
//

DELIMITER ;




DELIMITER //

CREATE TRIGGER trg_before_gift_card_update
BEFORE UPDATE ON gift_cards
FOR EACH ROW
BEGIN
    -- Check if current_balance is going to be negative
    IF NEW.current_balance < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance: cannot reduce below zero.';
    END IF;
END;
//

DELIMITER ;





DELIMITER //

CREATE TRIGGER trg_after_gift_card_update
AFTER UPDATE ON gift_cards
FOR EACH ROW
BEGIN
    -- If expiration_date is before today and status is not expired, set to expired
    IF NEW.expiration_date < CURDATE() AND NEW.status != 'expired' THEN
        UPDATE gift_cards
        SET status = 'expired'
        WHERE card_id = NEW.card_id;
    END IF;
END;
//

DELIMITER ;



DELIMITER //

CREATE TRIGGER trg_after_recharge_insert
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    -- Only check for 'recharge' txn_type
    IF NEW.txn_type = 'recharge' THEN

        -- Count number of recharges on this card in the last 1 minute
        SELECT COUNT(*)
        INTO v_count
        FROM transactions
        WHERE card_id = NEW.card_id
          AND txn_type = 'recharge'
          AND txn_date > DATE_SUB(NEW.txn_date, INTERVAL 1 MINUTE);

        -- If more than 3 recharges within 1 minute, log fraud
        IF v_count > 3 THEN
            INSERT INTO fraud_logs (card_id, user_id, event_type, event_description)
            VALUES (
                NEW.card_id,
                NULL,
                'rapid_redeem',
                'More than 3 recharges within 1 minute detected.'
            );
        END IF;

    END IF;
END;
//

DELIMITER ;





DELIMITER //

CREATE TRIGGER trg_block_after_failed_attempts
AFTER INSERT ON fraud_logs
FOR EACH ROW
BEGIN
    DECLARE failed_attempts INT;

    -- Count recent failed redemption attempts for this card
    SELECT COUNT(*)
    INTO failed_attempts
    FROM fraud_logs
    WHERE card_id = NEW.card_id
      AND event_type = 'multiple_failed_attempts'
      AND log_time > DATE_SUB(NOW(), INTERVAL 1 HOUR); -- adjust interval if needed

    -- If attempts exceed 3, block the card
    IF failed_attempts >= 3 THEN
        UPDATE gift_cards
        SET status = 'blocked'
        WHERE card_id = NEW.card_id;
    END IF;
END;
//

DELIMITER ;






DELIMITER //

CREATE TRIGGER trg_log_rapid_recharge
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE recent_txns INT;
    DECLARE v_user_id INT;

    -- Only apply this logic for recharge transactions
    IF NEW.txn_type = 'recharge' THEN

        -- Get the user associated with the card
        SELECT user_id INTO v_user_id
        FROM gift_cards
        WHERE card_id = NEW.card_id;

        -- Count recharge transactions within last 1 minute for this card
        SELECT COUNT(*)
        INTO recent_txns
        FROM transactions
        WHERE card_id = NEW.card_id
          AND txn_type = 'recharge'
          AND txn_date >= DATE_SUB(NOW(), INTERVAL 1 MINUTE);

        -- If more than 1 recharge in a short period, log it
        IF recent_txns > 1 THEN
            INSERT INTO fraud_logs (
                card_id, user_id, event_type, event_description
            )
            VALUES (
                NEW.card_id,
                v_user_id,
                'rapid_redeem',
                'Multiple rapid recharges detected within 1 minute'
            );
        END IF;
    END IF;
END;
//

DELIMITER ;








DELIMITER //

CREATE TRIGGER trg_prevent_redeem_blocked_or_inactive
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE v_status ENUM('active', 'inactive', 'blocked', 'expired');

    -- Only apply to redemption transactions
    IF NEW.txn_type IN ('redeem', 'partial_redeem') THEN
        -- Get the status of the card
        SELECT status INTO v_status
        FROM gift_cards
        WHERE card_id = NEW.card_id;

        -- Block the transaction if card is not active
        IF v_status IN ('inactive', 'blocked') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transaction denied: Card is inactive or blocked.';
        END IF;
    END IF;
END;
//

DELIMITER ;
