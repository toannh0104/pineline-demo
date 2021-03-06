-- +goose Up
-- SQL in this section is executed when the migration is applied.

INSERT  INTO payment_dev.service_group (service_group_id, service_group_name, description, is_deleted, created_timestamp, last_updated_timestamp) VALUES (99, 'Initial Service Group for fund-in', 'Initial Service Group', 0, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6));
INSERT  INTO payment_dev.service (service_id, service_name, service_group_id, currency, status, description, is_deleted, created_timestamp, last_updated_timestamp) VALUES (99, 'Initial Service for fund-in', 99, 'VND', 1, 'Initial Service', 0, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6));
INSERT  INTO payment_dev.service_command (service_command_id, service_id, command_id, is_deleted, created_timestamp, last_updated_timestamp) VALUES (99, 99, 1, 0, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6));
INSERT  INTO payment_dev.fee_tier (fee_tier_id, service_command_id, fee_tier_condition, condition_amount, fee_type, fee_amount, bonus_type, bonus_amount, amount_type, settlement_type, is_deleted, created_timestamp, last_updated_timestamp) VALUES (99, 99, 'unlimit', null, '% rate', 15.00000, 'NON', null, null, 'Amount', 0, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6));
INSERT  INTO payment_dev.balance_distribution (fee_tier_id, action_type, actor_type, specific_actor_id, sof_type_id, specific_sof, amount_type, rate, is_deleted, created_timestamp, last_updated_timestamp) VALUES (99, 'Debit', 'Payer', null, 2, null, 'Amount', null, 0, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6));
INSERT  INTO payment_dev.balance_distribution (fee_tier_id, action_type, actor_type, specific_actor_id, sof_type_id, specific_sof, amount_type, rate, is_deleted, created_timestamp, last_updated_timestamp) VALUES (99, 'Credit', 'Payee', null, 2, null, 'Amount', null, 0, CURRENT_TIMESTAMP(6), CURRENT_TIMESTAMP(6));

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.