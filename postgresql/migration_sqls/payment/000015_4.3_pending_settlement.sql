-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

CREATE TABLE payment_dev.settlement (
  id                        SERIAL         NOT NULL  PRIMARY KEY,
  description               VARCHAR(48)    NOT NULL,
  amount                    DECIMAL(20, 5) NOT NULL,
  payer_user_id             INT            NOT NULL,
  payer_user_type           VARCHAR(50)    NOT NULL,
  payer_sof_id              INT            NOT NULL,
  payer_sof_type_id         INT            NOT NULL,
  payee_user_id             INT            NOT NULL,
  payee_user_type           VARCHAR(50)    NOT NULL,
  payee_sof_id              INT            NOT NULL,
  payee_sof_type_id         INT            NOT NULL,
  currency                  VARCHAR(3)     NOT NULL,
  status                    VARCHAR(50)    NOT NULL,
  created_by                VARCHAR(50)    NOT NULL,
  created_user_id           INT            NOT NULL,
  last_updated_user_id      INT            NOT NULL,
  due_date                  TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ,
  created_timestamp         TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp    TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);
CREATE INDEX settlement_idx01 ON payment_dev.settlement (id);
CREATE INDEX settlement_idx02 ON payment_dev.settlement (description);
CREATE INDEX settlement_idx03 ON payment_dev.settlement (created_timestamp);
CREATE INDEX settlement_idx04 ON payment_dev.settlement (created_by);
CREATE INDEX settlement_idx05 ON payment_dev.settlement (due_date);
CREATE INDEX settlement_idx06 ON payment_dev.settlement (status);
CREATE INDEX settlement_idx07 ON payment_dev.settlement (payer_user_id);
CREATE INDEX settlement_idx08 ON payment_dev.settlement (payee_user_id);


CREATE TABLE payment_dev.unsettled_transaction (
  id                               SERIAL         NOT NULL  PRIMARY KEY,
  settlement_id                    INT            NOT NULL,
  reconciliation_id                INT            NOT NULL,
  internal_transaction_id          VARCHAR(256)   NULL,
  external_transaction_id          VARCHAR(256)   NULL,
  unsettled_amount_per_transaction DECIMAL(20, 5) NOT NULL,
  date_of_transaction              TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  reconciliation_from_date         TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  reconciliation_to_date           TIMESTAMP(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE INDEX unsettled_transaction_idx01 ON payment_dev.unsettled_transaction (internal_transaction_id);
CREATE INDEX unsettled_transaction_idx02 ON payment_dev.unsettled_transaction (external_transaction_id);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
DROP TABLE IF EXISTS payment_dev.settlement;
DROP TABLE IF EXISTS payment_dev.unsettled_transaction;

