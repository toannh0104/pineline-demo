-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.fee_tier_mask 
ADD COLUMN fee_tier_id INT NULL,
ADD COLUMN command_id INT NULL,
ADD COLUMN command_name VARCHAR(256) NULL;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET foreign_key_checks = 0;

ALTER TABLE payment_dev.fee_tier_mask DROP COLUMN command_name;
ALTER TABLE payment_dev.fee_tier_mask DROP COLUMN command_id;
ALTER TABLE payment_dev.fee_tier_mask DROP COLUMN fee_tier_id;

SET foreign_key_checks = 1;