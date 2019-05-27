-- +goose Up
-- SQL in this section is executed when the migration is applied.

USE payment_dev;
-- MISS NOT NULl
ALTER TABLE payment_dev.settlement_resolving_history 
  ALTER COLUMN order_id TYPE varchar(256);


-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

ALTER TABLE payment_dev.settlement_resolving_history MODIFY order_id INT NOT NULL;
