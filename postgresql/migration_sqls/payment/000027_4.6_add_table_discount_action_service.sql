-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE IF NOT EXISTS payment_dev.discount_action_service (
  id SERIAL NOT NULL,
  action_id INT NOT NULL,
  service_id INT NOT NULL,
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS=1;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS payment_dev.discount_action_service;

SET FOREIGN_KEY_CHECKS=1;