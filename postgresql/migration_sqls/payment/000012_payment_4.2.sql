-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

DROP INDEX tr_order_idx01 ON payment_dev.tr_order;
CREATE INDEX tr_order_idx01 ON payment_dev.tr_order (status);
DROP INDEX tr_order_idx02 ON payment_dev.tr_order;
DROP INDEX tr_order_idx13 ON payment_dev.tr_order;
CREATE INDEX tr_order_idx02 ON payment_dev.tr_order (state);
CREATE INDEX tr_order_idx13 ON payment_dev.tr_order (created_timestamp);
CREATE INDEX order_balance_movement_idx03 ON payment_dev.order_balance_movement (created_timestamp);
CREATE INDEX order_reference_idx02 ON payment_dev.order_reference (created_timestamp);


-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

DROP INDEX order_reference_idx02 ON payment_dev.order_reference;
DROP INDEX order_balance_movement_idx03 ON payment_dev.order_balance_movement;
DROP INDEX tr_order_idx13 ON payment_dev.tr_order;
DROP INDEX tr_order_idx02 ON payment_dev.tr_order;
CREATE INDEX tr_order_idx13 ON payment_dev.tr_order (state);
CREATE INDEX tr_order_idx02 ON payment_dev.tr_order (order_id, state);
DROP INDEX tr_order_idx01 ON payment_dev.tr_order;
CREATE INDEX tr_order_idx01 ON payment_dev.tr_order (order_id, status);
