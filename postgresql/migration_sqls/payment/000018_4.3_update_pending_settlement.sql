-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.settlement ADD COLUMN reconciliation_id INT NULL;
ALTER TABLE payment_dev.settlement ADD COLUMN reconciliation_from_date TIMESTAMP(6) NULL;
ALTER TABLE payment_dev.settlement ADD COLUMN reconciliation_to_date TIMESTAMP(6) NULL;

ALTER TABLE payment_dev.unsettled_transaction DROP COLUMN reconciliation_id;
ALTER TABLE payment_dev.unsettled_transaction DROP COLUMN reconciliation_from_date;
ALTER TABLE payment_dev.unsettled_transaction DROP COLUMN reconciliation_to_date;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

ALTER TABLE payment_dev.unsettled_transaction ADD COLUMN reconciliation_id INT NULL;
ALTER TABLE payment_dev.unsettled_transaction ADD COLUMN reconciliation_from_date TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6);
ALTER TABLE payment_dev.unsettled_transaction ADD COLUMN reconciliation_to_date TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6);

ALTER TABLE payment_dev.settlement DROP COLUMN reconciliation_id;
ALTER TABLE payment_dev.settlement DROP COLUMN reconciliation_from_date;
ALTER TABLE payment_dev.settlement DROP COLUMN reconciliation_to_date;
