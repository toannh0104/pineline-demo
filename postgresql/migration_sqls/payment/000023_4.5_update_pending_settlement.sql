-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.settlement ADD COLUMN settled_amount DECIMAL(20, 5) NULL;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET foreign_key_checks = 0;

ALTER TABLE payment_dev.settlement DROP COLUMN settled_amount;

SET foreign_key_checks = 1;