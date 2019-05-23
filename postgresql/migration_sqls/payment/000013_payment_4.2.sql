-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.service_tier_mask DROP INDEX name_tier;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

ALTER TABLE payment_dev.service_tier_mask ADD UNIQUE name_tier(name);