-- +goose Up
-- SQL in this section is executed when the migration is applied.

USE payment_dev;

CREATE TABLE IF NOT EXISTS payment_dev.settlement_configuration (
  id BIGSERIAL NOT NULL,
  currency varchar(3) NOT NULL,
  service_group_id BIGINT NOT NULL,
  service_id BIGINT NOT NULL,
  is_deleted tinyint(1) DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS payment_dev.settlement_resolving_history (
  id BIGSERIAL NOT NULL,
  settlement_id BIGINT NOT NULL,
  order_id BIGINT NOT NULL,
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id)
);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS payment_dev.settlement_configuration;
DROP TABLE IF EXISTS payment_dev.settlement_resolving_history;

SET FOREIGN_KEY_CHECKS=1;