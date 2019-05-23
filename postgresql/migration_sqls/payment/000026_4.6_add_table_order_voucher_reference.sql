-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;
CREATE TABLE payment_dev.order_voucher_reference (
  id SERIAL NOT NULL PRIMARY KEY,
  order_id varchar(256) NOT NULL,
  sender_name varchar(256),
  sender_phone_number varchar(256),
  receiver_name varchar(256),
  receiver_phone_number varchar(256),
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE OR REPLACE VIEW payment_dev.tr_order_detail AS
      SELECT
      o.order_id,
      o.ext_transaction_id,
      o.payment_method_name,
      o.payment_method_ref,
      o.service_id,
      o.service_name,
      o.command_id,
      o.command_name,
      o.service_command_id,
      o.requestor_user_id,
      o.requestor_user_type,
      CASE
          WHEN (o.requestor_user_type = 'customer') THEN (SELECT unique_reference FROM customer_dev.customer_profile WHERE id = o.requestor_user_id)
          WHEN (o.requestor_user_type = 'agent') THEN (SELECT unique_reference FROM agent_dev.agent_profile WHERE id = o.requestor_user_id)
      ELSE null
      END AS requestor_unique_reference,
      o.requestor_sof_id,
      o.requestor_sof_type_id,
      o.initiator_user_id,
      o.initiator_user_type,
      CASE
          WHEN (o.initiator_user_type = 'customer') THEN (SELECT unique_reference FROM customer_dev.customer_profile WHERE id = o.initiator_user_id)
          WHEN (o.initiator_user_type = 'agent') THEN (SELECT unique_reference FROM agent_dev.agent_profile WHERE id = o.initiator_user_id)
      ELSE null
      END AS initiator_unique_reference,
      o.initiator_sof_id,
      o.initiator_sof_type_id,
      o.payer_user_id,
      o.payer_user_type,
      CASE
          WHEN (o.payer_user_type = 'customer') THEN (SELECT CONCAT_WS (' ', first_name, last_name) FROM customer_dev.customer_profile WHERE id = o.payer_user_id)
          WHEN (o.payer_user_type = 'agent') THEN (SELECT CONCAT_WS (' ', first_name, last_name) FROM agent_dev.agent_profile WHERE id = o.payer_user_id)
      ELSE null
      END AS payer_user_name,
      CASE
          WHEN (o.payer_user_type = 'customer') THEN (SELECT unique_reference FROM customer_dev.customer_profile WHERE id = o.payer_user_id)
          WHEN (o.payer_user_type = 'agent') THEN (SELECT unique_reference FROM agent_dev.agent_profile WHERE id = o.payer_user_id)
      ELSE null
      END AS payer_unique_reference,
      o.payer_user_ref_type,
      o.payer_user_ref_value,
      o.payer_sof_id,
      o.payer_sof_type_id,
      o.payee_user_id,
      o.payee_user_type,
      CASE
          WHEN (o.payee_user_type = 'customer') THEN (SELECT CONCAT_WS (' ', first_name, last_name) FROM customer_dev.customer_profile WHERE id = o.payee_user_id)
          WHEN (o.payee_user_type = 'agent') THEN (SELECT CONCAT_WS (' ', first_name, last_name) FROM agent_dev.agent_profile WHERE id = o.payee_user_id)
      ELSE null
      END AS payee_user_name,
      CASE
          WHEN (o.payee_user_type = 'customer') THEN (SELECT unique_reference FROM customer_dev.customer_profile WHERE id = o.payee_user_id)
          WHEN (o.payee_user_type = 'agent') THEN (SELECT unique_reference FROM agent_dev.agent_profile WHERE id = o.payer_user_id)
      ELSE null
      END AS payee_unique_reference,
      o.payee_user_ref_type,
      o.payee_user_ref_value,
      o.payee_sof_id,
      o.payee_sof_type_id,
      o.currency,
      o.ref_order_id,
      o.amount,
      o.fee,
      o.bonus,
      o.settlement_amount,
      o.product_name,
      o.product_ref1,
      o.product_ref2,
      o.product_ref3,
      o.product_ref4,
      o.product_ref5,
      o.state,
      o.status,
      o.notification_status,
      o.is_deleted,
      o.created_timestamp,
      o.last_updated_timestamp,
      o.created_client_id,
      o.executed_client_id,
      o.security_ref,
      o.security_type_id,
      o.error_code,
      o.error_message,
      o.a,
      o.b,
      o.c,
      o.d,
      o.e,
      o.f,
      o.g,
      o.h,
      o.i,
      o.j,
      o.k,
      o.l,
      o.m,
      o.n,
      o.o,
      o.created_channel_type,
      o.created_device_unique_reference,
      o.short_order_id,
      o.wait_delay_timestamp,
      o.command_tier_mask_id,
      o.fee_tier_mask_id,
      o.is_allow_sub_balance
      FROM payment_dev.tr_order AS o;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
DROP  TABLE payment_dev.order_voucher_reference;
DROP VIEW IF EXISTS  payment_dev.tr_order_detail ;
