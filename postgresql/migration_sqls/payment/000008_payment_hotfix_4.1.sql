-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

CREATE TABLE payment_dev.order_locking (
  id                                        SERIAL                        NOT NULL PRIMARY KEY,
  order_id                                  VARCHAR(512)                              NOT NULL,
  order_detail_id                           VARCHAR(512)                              NULL,
  state                                     VARCHAR(512)                              NOT NULL,
  wait_duration_check_status_in_millisecond INT                                    NULL,
  max_retry_check_status                    INT                                    NULL,
  current_retry_check_status                INT                                    NULL,
  wait_duration_cancel_in_millisecond       INT                                    NULL,
  max_retry_cancel                          INT                                    NULL,
  current_retry_cancel                      INT                                    NULL,
  last_updated_by                           VARCHAR(512)                              NOT NULL,
  is_deleted                                SMALLINT                                  NOT NULL DEFAULT 0,
  created_timestamp                         TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL,
  last_updated_timestamp                    TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) NOT NULL

);
CREATE INDEX order_locking_idx01 ON payment_dev.order_locking (order_id);
CREATE INDEX order_locking_idx02 ON payment_dev.order_locking (state);
CREATE INDEX order_locking_idx03 ON payment_dev.order_locking (is_deleted);


-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET foreign_key_checks = 0;

DROP INDEX order_locking_idx03 ON payment_dev.order_locking;
DROP INDEX order_locking_idx02 ON payment_dev.order_locking;
DROP INDEX order_locking_idx01 ON payment_dev.order_locking;
DROP TABLE IF EXISTS payment_dev.order_locking;

SET foreign_key_checks = 1;
