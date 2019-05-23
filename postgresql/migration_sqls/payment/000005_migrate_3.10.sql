-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.order_balance_movement ADD COLUMN actor_type VARCHAR(256) NOT NULL DEFAULT 'N/A';
ALTER TABLE payment_dev.order_balance_movement ADD COLUMN debt_balance DECIMAL(20,5) NOT NULL DEFAULT 0;
CREATE TABLE payment_dev.sof_service_balance_limitation
(
  id                     SERIAL                         NOT NULL PRIMARY KEY,
  service_id             INT                                       NOT NULL,
  sof_id                 INT                                       NOT NULL,
  sof_type_id            INT                                       NOT NULL,
  maximum_amount         DECIMAL(20, 5)                            NOT NULL,
  is_deleted             SMALLINT DEFAULT '0'                    NOT NULL,
  created_timestamp      TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  last_updated_timestamp TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL
);
ALTER TABLE payment_dev.service ADD COLUMN is_allow_debt SMALLINT DEFAULT 0 NOT NULL;
ALTER TABLE payment_dev.tr_order 
    ADD COLUMN requestor_user_id BIGINT NULL DEFAULT NULL AFTER service_command_id,
    ADD COLUMN requestor_user_type VARCHAR(256) NULL DEFAULT NULL AFTER requestor_user_id,
    ADD COLUMN requestor_sof_id BIGINT NULL DEFAULT NULL AFTER requestor_user_type,
    ADD COLUMN requestor_sof_type_id BIGINT NULL DEFAULT NULL AFTER requestor_sof_id;
INSERT IGNORE INTO payment_dev.m_actor_type (actor_type_id, actor_type) VALUES ('7', 'Requestor');

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET foreign_key_checks = 0;

ALTER TABLE payment_dev.order_balance_movement DROP COLUMN actor_type;
ALTER TABLE payment_dev.order_balance_movement DROP COLUMN debt_balance;
DROP TABLE IF EXISTS payment_dev.sof_service_balance_limitation;
ALTER TABLE payment_dev.service DROP COLUMN is_allow_debt;
ALTER TABLE payment_dev.tr_order DROP COLUMN requestor_user_id;
ALTER TABLE payment_dev.tr_order DROP COLUMN requestor_user_type;
ALTER TABLE payment_dev.tr_order DROP COLUMN requestor_sof_id;
ALTER TABLE payment_dev.tr_order DROP COLUMN requestor_sof_type_id;
DELETE IGNORE FROM payment_dev.m_actor_type WHERE actor_type_id='7';

SET foreign_key_checks = 1;