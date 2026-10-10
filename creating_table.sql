-- ============================================================
-- Banking Transaction Fraud Detection & Analytics System
-- Step 7 + Step 8 : CREATE DATABASE + CREATE TABLE statements
-- MySQL 8.x
-- ============================================================

-- ------------------------------------------------------------
-- STEP 7 : CREATE DATABASE
-- ------------------------------------------------------------
DROP DATABASE IF EXISTS banking_fraud_detection;

CREATE DATABASE banking_fraud_detection
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE banking_fraud_detection;

-- ============================================================
-- STEP 8 : CREATE TABLES (dependency order: parents before children)
-- ============================================================

-- ------------------------------------------------------------
-- 1. customers  (no foreign keys — root table)
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id      INT AUTO_INCREMENT PRIMARY KEY,
    first_name       VARCHAR(50)  NOT NULL,
    last_name        VARCHAR(50)  NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    phone            VARCHAR(15)  NOT NULL UNIQUE,
    date_of_birth    DATE         NOT NULL,
    gender           VARCHAR(10),
    city             VARCHAR(50)  NOT NULL,
    state            VARCHAR(50)  NOT NULL,
    customer_since   DATE         NOT NULL,
    customer_status  VARCHAR(20)  NOT NULL DEFAULT 'active',
    CONSTRAINT chk_customer_status
        CHECK (customer_status IN ('active','inactive','suspended'))
);

-- ------------------------------------------------------------
-- 2. account_types  (no foreign keys — lookup table)
-- ------------------------------------------------------------
CREATE TABLE account_types (
    account_type_id    INT AUTO_INCREMENT PRIMARY KEY,
    account_type_name  VARCHAR(30)  NOT NULL UNIQUE,
    description         VARCHAR(255),
    minimum_balance     DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    interest_rate        DECIMAL(5,2)  DEFAULT 0.00,
    CONSTRAINT chk_account_type_min_balance CHECK (minimum_balance >= 0),
    CONSTRAINT chk_account_type_interest    CHECK (interest_rate >= 0)
);

-- ------------------------------------------------------------
-- 3. branches  (no foreign keys — lookup table)
-- ------------------------------------------------------------
CREATE TABLE branches (
    branch_id      INT AUTO_INCREMENT PRIMARY KEY,
    branch_name    VARCHAR(100) NOT NULL,
    branch_code    VARCHAR(20)  NOT NULL UNIQUE,
    city           VARCHAR(50)  NOT NULL,
    state          VARCHAR(50)  NOT NULL,
    address        VARCHAR(255),
    manager_name   VARCHAR(100),
    opened_date    DATE
);

-- ------------------------------------------------------------
-- 4. merchants  (no foreign keys — lookup table)
-- ------------------------------------------------------------
CREATE TABLE merchants (
    merchant_id        INT AUTO_INCREMENT PRIMARY KEY,
    merchant_name      VARCHAR(100) NOT NULL,
    merchant_category  VARCHAR(50)  NOT NULL,
    city               VARCHAR(50),
    state              VARCHAR(50),
    country            VARCHAR(50)  NOT NULL DEFAULT 'India',
    risk_level         VARCHAR(20)  NOT NULL DEFAULT 'low',
    merchant_status    VARCHAR(20)  NOT NULL DEFAULT 'active',
    CONSTRAINT chk_merchant_risk_level
        CHECK (risk_level IN ('low','medium','high'))
);

-- ------------------------------------------------------------
-- 5. locations  (no foreign keys — lookup table)
-- ------------------------------------------------------------
CREATE TABLE locations (
    location_id     INT AUTO_INCREMENT PRIMARY KEY,
    location_name   VARCHAR(100),
    city            VARCHAR(50)  NOT NULL,
    state           VARCHAR(50)  NOT NULL,
    country         VARCHAR(50)  NOT NULL DEFAULT 'India',
    latitude        DECIMAL(10,7),
    longitude       DECIMAL(10,7),
    location_type   VARCHAR(30)  NOT NULL,
    CONSTRAINT chk_location_type
        CHECK (location_type IN ('ATM','POS','Branch','Online','Mobile'))
);

-- ------------------------------------------------------------
-- 6. devices  (no foreign keys — lookup table)
-- ------------------------------------------------------------
CREATE TABLE devices (
    device_id          INT AUTO_INCREMENT PRIMARY KEY,
    device_identifier  VARCHAR(100) NOT NULL UNIQUE,
    device_type        VARCHAR(30)  NOT NULL,
    operating_system   VARCHAR(30),
    browser            VARCHAR(50),
    registered_date    DATE         NOT NULL,
    device_status      VARCHAR(20)  NOT NULL DEFAULT 'active'
);

-- ------------------------------------------------------------
-- 7. transaction_types  (no foreign keys — lookup table)
-- ------------------------------------------------------------
CREATE TABLE transaction_types (
    transaction_type_id    INT AUTO_INCREMENT PRIMARY KEY,
    transaction_type_name  VARCHAR(50) NOT NULL UNIQUE,
    transaction_category   VARCHAR(30) NOT NULL,
    description             VARCHAR(255)
);

-- ------------------------------------------------------------
-- 8. fraud_rules  (no foreign keys — lookup/config table)
-- ------------------------------------------------------------
CREATE TABLE fraud_rules (
    fraud_rule_id      INT AUTO_INCREMENT PRIMARY KEY,
    rule_name          VARCHAR(100) NOT NULL UNIQUE,
    rule_description   VARCHAR(255),
    risk_level         VARCHAR(20)  NOT NULL,
    threshold_value    DECIMAL(15,2),
    rule_status        VARCHAR(20)  NOT NULL DEFAULT 'active',
    CONSTRAINT chk_fraud_rule_risk_level
        CHECK (risk_level IN ('low','medium','high'))
);

-- ------------------------------------------------------------
-- 9. accounts  (depends on: customers, account_types, branches)
-- ------------------------------------------------------------
CREATE TABLE accounts (
    account_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id       INT NOT NULL,
    account_type_id   INT NOT NULL,
    branch_id         INT NOT NULL,
    account_number    VARCHAR(20)   NOT NULL UNIQUE,
    opening_date      DATE          NOT NULL,
    current_balance   DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    account_status    VARCHAR(20)   NOT NULL DEFAULT 'active',
    credit_limit      DECIMAL(15,2) DEFAULT 0.00,
    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_accounts_account_type
        FOREIGN KEY (account_type_id) REFERENCES account_types(account_type_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_accounts_branch
        FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_account_status
        CHECK (account_status IN ('active','inactive','suspended','closed')),
    CONSTRAINT chk_account_credit_limit CHECK (credit_limit >= 0)
);

CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);

-- ------------------------------------------------------------
-- 10. transactions  (depends on: accounts, transaction_types,
--                     merchants, locations, devices)
-- ------------------------------------------------------------
CREATE TABLE transactions (
    transaction_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id            INT NOT NULL,
    transaction_type_id   INT NOT NULL,
    merchant_id           INT NOT NULL,
    location_id           INT NOT NULL,
    device_id             INT NOT NULL,
    transaction_amount    DECIMAL(15,2) NOT NULL,
    transaction_date      DATETIME      NOT NULL,
    transaction_status    VARCHAR(20)   NOT NULL,
    reference_number      VARCHAR(50)   NOT NULL UNIQUE,
    description            VARCHAR(255),
    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_transactions_type
        FOREIGN KEY (transaction_type_id) REFERENCES transaction_types(transaction_type_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_transactions_merchant
        FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_transactions_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_transactions_device
        FOREIGN KEY (device_id) REFERENCES devices(device_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_transaction_amount CHECK (transaction_amount > 0),
    CONSTRAINT chk_transaction_status
        CHECK (transaction_status IN ('success','failed','pending'))
);

CREATE INDEX idx_transactions_account_id      ON transactions(account_id);
CREATE INDEX idx_transactions_date            ON transactions(transaction_date);
CREATE INDEX idx_transactions_device_id       ON transactions(device_id);
CREATE INDEX idx_transactions_account_date    ON transactions(account_id, transaction_date);

-- ------------------------------------------------------------
-- 11. fraud_alerts  (depends on: transactions, fraud_rules)
-- ------------------------------------------------------------
CREATE TABLE fraud_alerts (
    alert_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id   BIGINT NOT NULL,
    fraud_rule_id    INT NOT NULL,
    alert_date       DATETIME      NOT NULL,
    risk_score       DECIMAL(5,2)  NOT NULL,
    risk_level       VARCHAR(20)   NOT NULL,
    alert_status     VARCHAR(30)   NOT NULL DEFAULT 'open',
    reviewed_date    DATETIME  NULL,
    resolution       VARCHAR(255)  NULL,
    CONSTRAINT fk_fraud_alerts_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_fraud_alerts_rule
        FOREIGN KEY (fraud_rule_id) REFERENCES fraud_rules(fraud_rule_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_fraud_alert_risk_score CHECK (risk_score BETWEEN 0 AND 100),
    CONSTRAINT chk_fraud_alert_risk_level
        CHECK (risk_level IN ('low','medium','high'))
);

CREATE INDEX idx_fraud_alerts_transaction_id ON fraud_alerts(transaction_id);
CREATE INDEX idx_fraud_alerts_rule_id        ON fraud_alerts(fraud_rule_id);

-- ------------------------------------------------------------
-- 12. login_attempts  (depends on: accounts, devices, locations)
-- ------------------------------------------------------------
CREATE TABLE login_attempts (
    login_attempt_id  BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id        INT NOT NULL,
    device_id         INT NOT NULL,
    location_id       INT NOT NULL,
    login_time        DATETIME    NOT NULL,
    login_status      VARCHAR(20) NOT NULL,
    failure_reason    VARCHAR(255) NULL,
    CONSTRAINT fk_login_attempts_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_login_attempts_device
        FOREIGN KEY (device_id) REFERENCES devices(device_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_login_attempts_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_login_status
        CHECK (login_status IN ('success','failed'))
);

CREATE INDEX idx_login_attempts_account_id ON login_attempts(account_id);
CREATE INDEX idx_login_attempts_login_time ON login_attempts(login_time);

-- ------------------------------------------------------------
-- 13. account_status_history  (depends on: accounts)
-- ------------------------------------------------------------
CREATE TABLE account_status_history (
    history_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id    INT NOT NULL,
    old_status    VARCHAR(20) NULL,
    new_status    VARCHAR(20) NOT NULL,
    changed_at    DATETIME    NOT NULL,
    reason        VARCHAR(255),
    CONSTRAINT fk_status_history_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_status_history_account_id ON account_status_history(account_id);

-- ============================================================
-- END OF SCHEMA CREATION
-- ============================================================