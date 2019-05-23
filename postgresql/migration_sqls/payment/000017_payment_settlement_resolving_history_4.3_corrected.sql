-- +goose Up
-- SQL in this section is executed when the migration is applied.

USE payment_dev;
ALTER TABLE payment_dev.settlement_resolving_history ADD COLUMN settlement_configuration_id INT NOT NULL;


-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

ALTER TABLE payment_dev.settlement_resolving_history DROP COLUMN settlement_configuration_id;