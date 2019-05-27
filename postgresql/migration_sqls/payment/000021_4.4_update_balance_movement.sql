

-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.order_balance_movement ADD COLUMN  error_code varchar(100) DEFAULT NULL;
ALTER TABLE payment_dev.order_balance_movement ADD COLUMN  error_message varchar(256) DEFAULT NULL;



-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET foreign_key_checks = 0;

ALTER TABLE payment_dev.order_balance_movement DROP COLUMN `error_code`;
ALTER TABLE payment_dev.order_balance_movement DROP COLUMN `error_message`;

SET foreign_key_checks = 1;