-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

-- 3.7.8
CREATE INDEX tr_order_idx13 ON payment_dev.tr_order (state);

-- 3.8
ALTER TABLE payment_dev.order_balance_movement 
	ADD COLUMN voucher_id INT NULL,
	ADD COLUMN voucher_code VARCHAR(256) NULL;

ALTER TABLE payment_dev.order_balance_movement
	ADD COLUMN original_balance_movement_id VARCHAR(256) NULL;

CREATE OR REPLACE VIEW payment_dev.user_company AS
 	SELECT
	    a.id AS id,
	    a.id AS user_id,
	    'agent' AS user_type,
	    a.company_id AS company_id,
	    0 AS is_deleted
	FROM agent_dev.agent_profile AS a
	WHERE (a.company_id IS NOT NULL)
	UNION ALL
	SELECT
	    c.id AS id,
	    c.customer_id AS user_id,
	    'customer' AS user_type,
	    c.company_id AS company_id,
	    c.is_deleted AS is_deleted
	FROM customer_dev.customer_company AS c;

-- 3.9
ALTER TABLE payment_dev.service ADD COLUMN apply_to_all_company_type SMALLINT DEFAULT 0 NOT NULL;
ALTER TABLE payment_dev.service ADD COLUMN apply_to_all_customer_classification SMALLINT DEFAULT 0 NOT NULL;
CREATE TABLE IF NOT EXISTS payment_dev.service_company_type
(
    id SERIAL PRIMARY KEY,
    service_id INT NOT NULL,
    company_type_id INT NOT NULL,
    CONSTRAINT service_company_type_fk01 FOREIGN KEY (service_id) REFERENCES payment_dev.service (service_id)
);
CREATE TABLE IF NOT EXISTS payment_dev.command_tier_mask
(
    id SERIAL PRIMARY KEY,
    service_command_id INT NOT NULL,
    tier_level_name varchar(256),
    number_of_time INT,
    is_deleted TINYINT NOT NULL DEFAULT 0,
    created_timestamp TIMESTAMP(6)  DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
    last_updated_timestamp TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL
);
CREATE TABLE IF NOT EXISTS payment_dev.service_customer_classification
(
  id SERIAL NOT NULL PRIMARY KEY,
  service_id INT NOT NULL,
  customer_classification_id INT NOT NULL
);
CREATE INDEX service_customer_classification_fk01 ON payment_dev.service_customer_classification (service_id);
CREATE INDEX service_customer_classification_fk02 ON payment_dev.service_customer_classification (customer_classification_id);
INSERT IGNORE INTO payment_dev.m_security_type (id, name) VALUES (3 ,'Internal OTP');
ALTER TABLE payment_dev.tr_order ADD COLUMN command_tier_mask_id INT;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET foreign_key_checks = 0;

-- 3.7.8
DROP INDEX tr_order_idx13 ON payment_dev.tr_order;

-- 3.8
ALTER TABLE payment_dev.order_balance_movement DROP COLUMN voucher_id;
ALTER TABLE payment_dev.order_balance_movement DROP COLUMN voucher_code;
ALTER TABLE payment_dev.order_balance_movement DROP COLUMN original_balance_movement_id;
DROP VIEW IF EXISTS payment_dev.user_company;

-- 3.9
ALTER TABLE payment_dev.service DROP COLUMN apply_to_all_company_type;
ALTER TABLE payment_dev.service DROP COLUMN apply_to_all_customer_classification;
DROP TABLE IF EXISTS payment_dev.service_company_type;
DROP TABLE IF EXISTS payment_dev.command_tier_mask;
DROP INDEX service_customer_classification_fk01 ON payment_dev.service_customer_classification;
DROP INDEX service_customer_classification_fk02 ON payment_dev.service_customer_classification;
DROP TABLE IF EXISTS payment_dev.service_customer_classification;
DELETE IGNORE FROM payment_dev.m_security_type WHERE id=3;
ALTER TABLE payment_dev.tr_order DROP COLUMN command_tier_mask_id;

SET foreign_key_checks = 1;