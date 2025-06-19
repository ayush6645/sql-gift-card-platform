DELIMITER //

CREATE PROCEDURE generate_gift_card (
    IN p_card_code VARCHAR(50),
    IN p_initial_balance DECIMAL(10,2),
    IN p_expiration_date DATE,
    IN p_user_id INT -- Can be NULL if unassigned
)
BEGIN
    /*
    Procedure: generate_gift_card
    Purpose: Create a new gift card record with the specified details.
    Parameters:
      p_card_code       - Unique code identifier for the gift card
      p_initial_balance - Starting balance for the card
      p_expiration_date - Expiration date of the card
      p_user_id         - Optional user ID the card is assigned to (NULL if unassigned)
    */

    -- Insert the new gift card with initial and current balance set the same
    INSERT INTO gift_cards (
        card_code,
        initial_balance,
        current_balance,
        expiration_date,
        status,
        user_id,
        assigned_at,
        created_at
    )
    VALUES (
        p_card_code,
        p_initial_balance,
        p_initial_balance,
        p_expiration_date,
        'active',
        p_user_id,
        CASE WHEN p_user_id IS NOT NULL THEN NOW() ELSE NULL END,
        NOW()
    );
END;
//

DELIMITER ;



DELIMITER //

CREATE PROCEDURE redeem_gift_card (
    IN p_card_code VARCHAR(50),
    IN p_redeem_amount DECIMAL(10,2)
)
BEGIN
    /*
    Procedure: redeem_gift_card
    Purpose: Redeem an amount from the gift card balance.
    Parameters:
      p_card_code     - The unique code of the gift card to redeem from
      p_redeem_amount - The amount to deduct from the gift card balance
    */

    DECLARE v_card_id INT;
    DECLARE v_current_balance DECIMAL(10,2);
    DECLARE v_expired BOOLEAN;
    DECLARE v_status VARCHAR(20);
    DECLARE v_err_msg VARCHAR(255);

    -- Get card details to validate
    SELECT card_id, current_balance, (expiration_date < CURDATE()), status
    INTO v_card_id, v_current_balance, v_expired, v_status
    FROM gift_cards
    WHERE card_code = p_card_code;

    -- Check if card exists
    IF v_card_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card not found.';
    END IF;

    -- Check if card is expired
    IF v_expired THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card has expired.';
    END IF;

    -- Check if card status allows redemption
    IF v_status != 'active' THEN
        SET v_err_msg = CONCAT('Gift card status is ', v_status, '. Redemption not allowed.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_err_msg;
    END IF;

    -- Check if sufficient balance
    IF v_current_balance < p_redeem_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance on gift card.';
    END IF;

    -- Deduct the redeem amount from current balance
    UPDATE gift_cards
    SET current_balance = current_balance - p_redeem_amount
    WHERE card_id = v_card_id;

    -- Log the redemption transaction
    INSERT INTO transactions (card_id, txn_type, amount, description)
    VALUES (v_card_id, 'redeem', p_redeem_amount, CONCAT('Redeemed ', p_redeem_amount, ' from card ', p_card_code));

END;
//

DELIMITER ;



DELIMITER //

CREATE EVENT IF NOT EXISTS auto_expire_gift_cards
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
BEGIN
    -- Update gift cards that have expired but are not yet marked as expired
    UPDATE gift_cards
    SET status = 'expired'
    WHERE expiration_date < CURDATE()
      AND status != 'expired';
END;
//

DELIMITER ;




DELIMITER //

CREATE PROCEDURE recharge_gift_card(
    IN p_card_code VARCHAR(50),
    IN p_recharge_amount DECIMAL(10,2)
)
BEGIN
    /*
    Procedure: recharge_gift_card
    Purpose: Add funds to an existing gift card's balance.
    Parameters:
      p_card_code      - The unique code of the gift card to recharge
      p_recharge_amount - The amount to add to the gift card balance
    */

    DECLARE v_card_id INT;
    DECLARE v_current_balance DECIMAL(10,2);
    DECLARE v_expired BOOLEAN;
    DECLARE v_status VARCHAR(20);
    DECLARE v_error_msg VARCHAR(255);

    -- Get card details to validate
    SELECT card_id, current_balance, (expiration_date < CURDATE()), status
    INTO v_card_id, v_current_balance, v_expired, v_status
    FROM gift_cards
    WHERE card_code = p_card_code;

    -- Check if card exists
    IF v_card_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card not found.';
    END IF;

    -- Check if card is expired
    IF v_expired THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card has expired.';
    END IF;

    -- Check if card status allows recharge
    IF v_status != 'active' THEN
        SET v_error_msg = CONCAT('Gift card status is ', v_status, '. Recharge not allowed.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
    END IF;

    -- Update the card balance by adding recharge amount
    UPDATE gift_cards
    SET current_balance = current_balance + p_recharge_amount
    WHERE card_id = v_card_id;

    -- Log the recharge transaction
    INSERT INTO transactions (card_id, txn_type, amount, description)
    VALUES (v_card_id, 'recharge', p_recharge_amount, CONCAT('Recharged ', p_recharge_amount, ' to card ', p_card_code));

END;
//

DELIMITER ;





DELIMITER //

CREATE PROCEDURE transfer_gift_card(
    IN p_card_code VARCHAR(50),
    IN p_from_user_id INT,
    IN p_to_user_id INT,
    IN p_transfer_reason VARCHAR(255)
)
BEGIN
    /*
    Procedure: transfer_gift_card
    Purpose: Transfer a gift card from one user to another.
    Parameters:
      p_card_code      - The unique gift card code to transfer
      p_from_user_id   - User ID who currently owns the card
      p_to_user_id     - User ID who will receive the card
      p_transfer_reason - Optional reason/comment for the transfer
    */

    DECLARE v_card_id INT;
    DECLARE v_current_owner INT;
    DECLARE v_status VARCHAR(20);

    -- Get card details
    SELECT card_id, user_id, status
    INTO v_card_id, v_current_owner, v_status
    FROM gift_cards
    WHERE card_code = p_card_code;

    -- Check if card exists
    IF v_card_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card not found.';
    END IF;

    -- Verify the card belongs to from_user_id
    IF v_current_owner IS NULL OR v_current_owner != p_from_user_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card does not belong to the specified from_user.';
    END IF;

    -- Check if card status is active
    IF v_status != 'active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gift card is not active. Transfer not allowed.';
    END IF;

    -- Update gift_cards table to assign the card to new user and update assigned_at timestamp
    UPDATE gift_cards
    SET user_id = p_to_user_id,
        assigned_at = NOW()
    WHERE card_id = v_card_id;

    -- Log the transfer in gift_card_transfers table
    INSERT INTO gift_card_transfers (card_id, from_user_id, to_user_id, transfer_reason, transfer_date)
    VALUES (v_card_id, p_from_user_id, p_to_user_id, p_transfer_reason, NOW());

END;
//

DELIMITER ;






DELIMITER //

CREATE PROCEDURE bulk_generate_gift_cards (
    IN p_prefix VARCHAR(20),
    IN p_count INT,
    IN p_initial_balance DECIMAL(10,2),
    IN p_expiration_date DATE,
    IN p_user_id INT -- pass NULL if unassigned cards
)
BEGIN
    DECLARE v_counter INT DEFAULT 1;
    DECLARE v_card_code VARCHAR(50);
    
    WHILE v_counter <= p_count DO
        -- Generate unique card code: prefix + timestamp + counter
        SET v_card_code = CONCAT(p_prefix, DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), LPAD(v_counter, 4, '0'));
        
        INSERT INTO gift_cards (
            card_code, initial_balance, current_balance, expiration_date, user_id, created_at
        ) VALUES (
            v_card_code, p_initial_balance, p_initial_balance, p_expiration_date, p_user_id, NOW()
        );
        
        SET v_counter = v_counter + 1;
    END WHILE;
END;
//

DELIMITER ;