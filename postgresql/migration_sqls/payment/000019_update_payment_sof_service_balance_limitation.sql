-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.sof_service_balance_limitation ALTER COLUMN maximum_amount TYPE DECIMAL(20,5);
ALTER TABLE payment_dev.sof_service_balance_limitation ADD COLUMN minimum_amount DECIMAL(20,5) NULL;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

ALTER TABLE payment_dev.sof_service_balance_limitation MODIFY maximum_amount DECIMAL(20,5) NOT NULL;
ALTER TABLE payment_dev.sof_service_balance_limitation DROP COLUMN minimum_amount;
