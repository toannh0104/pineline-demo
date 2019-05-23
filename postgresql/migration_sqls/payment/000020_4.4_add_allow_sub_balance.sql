-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.tr_order ADD COLUMN is_allow_sub_balance SMALLINT NULL;



-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET foreign_key_checks = 0;

ALTER TABLE payment_dev.tr_order DROP COLUMN is_allow_sub_balance;

SET foreign_key_checks = 1;