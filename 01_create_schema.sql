DROP DATABASE IF EXISTS gift_card_platform;
CREATE DATABASE gift_card_platform;
USE gift_card_platform;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE gift_cards (
    card_id INT AUTO_INCREMENT PRIMARY KEY,
    card_code VARCHAR(50) UNIQUE NOT NULL,
    initial_balance DECIMAL(10,2) NOT NULL,
    current_balance DECIMAL(10,2) NOT NULL,
    expiration_date DATE NOT NULL,
    status ENUM('active', 'inactive', 'blocked', 'expired') DEFAULT 'active',
    user_id INT NULL,
    assigned_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE SET NULL
);

CREATE TABLE transactions (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    card_id INT NOT NULL,
    txn_type ENUM('redeem', 'partial_redeem', 'recharge') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    txn_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (card_id) REFERENCES gift_cards(card_id)
        ON DELETE CASCADE
);

CREATE TABLE gift_card_transfers (
    transfer_id INT AUTO_INCREMENT PRIMARY KEY,
    card_id INT NOT NULL,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    transfer_reason VARCHAR(255),
    transfer_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (card_id) REFERENCES gift_cards(card_id)
        ON DELETE CASCADE,
    FOREIGN KEY (from_user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE fraud_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    card_id INT,
    user_id INT,
    event_type ENUM('suspicious_redeem', 'multiple_failed_attempts', 'rapid_redeem') NOT NULL,
    event_description TEXT,
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (card_id) REFERENCES gift_cards(card_id)
        ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE SET NULL
);














