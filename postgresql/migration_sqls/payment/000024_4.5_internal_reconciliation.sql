-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.order_balance_movement ADD COLUMN   reconciliation_status VARCHAR(30) NOT NULL DEFAULT 'PENDING';
ALTER TABLE payment_dev.order_balance_movement ADD COLUMN   reconciliation_id INT  NULL;

CREATE INDEX order_balance_movement_idx04 ON payment_dev.order_balance_movement (reconciliation_status);
CREATE INDEX order_balance_movement_idx05 ON payment_dev.order_balance_movement (reconciliation_id);
CREATE INDEX order_balance_movement_idx06 ON payment_dev.order_balance_movement (amount);
CREATE INDEX  tr_order_idx14 ON payment_dev.tr_order (last_updated_timestamp);

CREATE OR REPLACE VIEW payment_dev.v_reconcile_order_balance_movement AS
 	SELECT 
		x.order_id,
        x.order_balance_movement_id,
        x.user_id as payee_user_id,
        x.user_type_id as payee_user_type_id,
        y.service_id,
		x.amount_type as tier_label,
		z.currency,
		x.amount,
		x.action_type,
		y.product_ref1,
		y.product_ref2,
		y.product_ref3,
		y.product_ref4,
		y.product_ref5,
		y.product_name,
		y.last_updated_timestamp as order_last_updated_timestamp,
        x.reconciliation_status,
        x.reconciliation_id
		FROM payment_dev.order_balance_movement x JOIN payment_dev.tr_order y ON x.order_id = y.order_id
		JOIN payment_dev.service z ON y.service_id=z.service_id
		WHERE y.status in (2,3) ;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
SET foreign_key_checks = 0;

ALTER TABLE payment_dev.order_balance_movement DROP COLUMN reconciliation_status;
ALTER TABLE payment_dev.order_balance_movement DROP COLUMN internal_reconciliation_id;

SET foreign_key_checks = 1;