-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

CREATE TABLE payment_dev.m_service_transaction_limitation_equation (
  id   INT          NOT NULL,
  name VARCHAR(512) NOT NULL
);
INSERT IGNORE INTO payment_dev.m_service_transaction_limitation_equation(id, name) VALUES (1,'Sum of the transaction values (absolute amount of credit and debit)');
CREATE TABLE payment_dev.service_limitation (
  id                        SERIAL         NOT NULL  PRIMARY KEY,
  service_id                INT            NOT NULL,
  limitation_type           VARCHAR(32)    NOT NULL,
  equation_id               INT            NULL,
  limitation_value          DECIMAL(20, 5) NOT NULL,
  current_value             DECIMAL(20, 5) NOT NULL,
  reset_time_block_value    INT            NOT NULL,
  reset_time_block_unit     VARCHAR(32)    NOT NULL,
  is_deleted                SMALLINT     NOT NULL DEFAULT 0,
  next_reset_timestamp      TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  start_effective_timestamp TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  end_effective_timestamp   TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  created_timestamp         TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp    TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);
CREATE INDEX service_limitation_idx01 ON payment_dev.service_limitation (service_id);
CREATE INDEX service_limitation_idx02 ON payment_dev.service_limitation (limitation_type);
CREATE INDEX service_limitation_idx03 ON payment_dev.service_limitation (is_deleted);
CREATE INDEX service_limitation_idx04 ON payment_dev.service_limitation (start_effective_timestamp);
CREATE INDEX service_limitation_idx05 ON payment_dev.service_limitation (end_effective_timestamp);

CREATE TABLE payment_dev.service_limitation_condition (
  id                      SERIAL       NOT NULL  PRIMARY KEY,
  service_limitation_id   INT          NOT NULL ,
  actor                   VARCHAR(256) NOT NULL,
  actor_user_type         VARCHAR(256) NOT NULL,
  actor_type_id           INT          NULL,
  actor_classification_id INT          NULL,
  is_deleted              SMALLINT   NOT NULL DEFAULT 0,
  created_timestamp       TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp  TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);
CREATE INDEX service_limitation_condition_idx01 ON payment_dev.service_limitation_condition (actor);
CREATE INDEX service_limitation_condition_idx02 ON payment_dev.service_limitation_condition (actor_user_type);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET foreign_key_checks = 0;

DELETE IGNORE FROM payment_dev.m_service_transaction_limitation_equation WHERE id=1;
DROP TABLE IF EXISTS payment_dev.m_service_transaction_limitation_equation;

DROP INDEX service_limitation_condition_idx01 ON payment_dev.service_limitation_condition;
DROP INDEX service_limitation_condition_idx02 ON payment_dev.service_limitation_condition;
DROP TABLE IF EXISTS payment_dev.service_limitation_condition;
DROP INDEX service_limitation_idx01 ON payment_dev.service_limitation;
DROP INDEX service_limitation_idx02 ON payment_dev.service_limitation;
DROP INDEX service_limitation_idx03 ON payment_dev.service_limitation;
DROP INDEX service_limitation_idx04 ON payment_dev.service_limitation;
DROP INDEX service_limitation_idx05 ON payment_dev.service_limitation;
DROP TABLE IF EXISTS payment_dev.service_limitation;

SET foreign_key_checks = 1;
