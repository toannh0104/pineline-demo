-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.service ADD COLUMN hierarchy_dependent SMALLINT default 0;
ALTER TABLE payment_dev.service ADD COLUMN hierarchy_dependent_actor varchar(256);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET foreign_key_checks = 0;

ALTER TABLE payment_dev.service DROP COLUMN `hierarchy_dependent`;
ALTER TABLE payment_dev.service DROP COLUMN `hierarchy_dependent_actor`;

SET foreign_key_checks = 1;