-- +goose Up
-- SQL in this section is executed when the migration is applied.

CREATE SCHEMA IF NOT EXISTS payment_dev AUTHORIZATION DB_RW_USERNAME_PAYMENT;
GRANT CONNECT ON DATABASE payment_dev TO DB_RW_USERNAME_PAYMENT;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA payment_dev TO DB_RW_USERNAME_PAYMENT;
SET search_path TO payment_dev;

CREATE TABLE IF NOT EXISTS payment_dev.agent_bonus_distribution (
  agent_bonus_distribution_id BIGSERIAL,
  fee_tier_id BIGINT NOT NULL,
  action_type varchar(256) NOT NULL,
  actor_type varchar(256) DEFAULT NULL,
  specific_actor_id BIGINT DEFAULT NULL,
  sof_type_id BIGINT DEFAULT NULL,
  specific_sof BIGINT DEFAULT NULL,
  amount_type varchar(256) DEFAULT NULL,
  rate decimal(15,5) DEFAULT NULL,
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (agent_bonus_distribution_id)
);

CREATE INDEX agent_bonus_distribution_idx01 ON payment_dev.agent_bonus_distribution (fee_tier_id);

CREATE TABLE IF NOT EXISTS payment_dev.agent_fee_distribution (
  agent_fee_distribution_id BIGSERIAL,
  fee_tier_id BIGINT NOT NULL,
  action_type varchar(256) NOT NULL,
  actor_type varchar(256) DEFAULT NULL,
  specific_actor_id BIGINT DEFAULT NULL,
  sof_type_id BIGINT DEFAULT NULL,
  specific_sof BIGINT DEFAULT NULL,
  amount_type varchar(256) DEFAULT NULL,
  rate decimal(15,5) DEFAULT NULL,
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (agent_fee_distribution_id)
);

CREATE INDEX agent_fee_distribution_idx01 ON payment_dev.agent_fee_distribution (fee_tier_id);

CREATE TABLE IF NOT EXISTS payment_dev.balance_distribution (
  balance_distribution_id BIGSERIAL,
  fee_tier_id BIGINT NOT NULL,
  action_type varchar(256) NOT NULL,
  actor_type varchar(256) DEFAULT NULL,
  specific_actor_id BIGINT DEFAULT NULL,
  sof_type_id BIGINT DEFAULT NULL,
  specific_sof BIGINT DEFAULT NULL,
  amount_type varchar(256) DEFAULT NULL,
  rate decimal(15,5) DEFAULT NULL,
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  remark varchar(256) DEFAULT NULL,
  PRIMARY KEY (balance_distribution_id)
);

CREATE INDEX balance_distribution_idx01 ON payment_dev.balance_distribution (fee_tier_id);

CREATE TABLE IF NOT EXISTS payment_dev.bonus_distribution (
  bonus_distribution_id BIGSERIAL,
  fee_tier_id BIGINT NOT NULL,
  action_type varchar(256) NOT NULL,
  actor_type varchar(256) DEFAULT NULL,
  specific_actor_id BIGINT DEFAULT NULL,
  sof_type_id BIGINT DEFAULT NULL,
  specific_sof BIGINT DEFAULT NULL,
  amount_type varchar(256) DEFAULT NULL,
  rate decimal(15,5) DEFAULT NULL,
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (bonus_distribution_id)
);

CREATE INDEX bonus_distribution_idx01 ON payment_dev.bonus_distribution (fee_tier_id);

CREATE TABLE IF NOT EXISTS payment_dev.fee_tier (
  fee_tier_id BIGSERIAL,
  service_command_id BIGINT NOT NULL,
  fee_tier_condition varchar(256) DEFAULT NULL,
  condition_amount decimal(15,5) DEFAULT NULL,
  fee_type varchar(256) DEFAULT NULL,
  fee_amount decimal(15,5) DEFAULT NULL,
  bonus_type varchar(256) DEFAULT NULL,
  bonus_amount decimal(15,5) DEFAULT NULL,
  amount_type varchar(256) DEFAULT NULL,
  settlement_type varchar(256) DEFAULT NULL,
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  a_type_first varchar(256) DEFAULT NULL,
  a_from_first varchar(256) DEFAULT NULL,
  a_amount_first decimal(15,5) DEFAULT NULL,
  a_operator varchar(256) DEFAULT NULL,
  a_type_second varchar(256) DEFAULT NULL,
  a_from_second varchar(256) DEFAULT NULL,
  a_amount_second decimal(15,5) DEFAULT NULL,
  b_type_first varchar(256) DEFAULT NULL,
  b_from_first varchar(256) DEFAULT NULL,
  b_amount_first decimal(15,5) DEFAULT NULL,
  b_operator varchar(256) DEFAULT NULL,
  b_type_second varchar(256) DEFAULT NULL,
  b_from_second varchar(256) DEFAULT NULL,
  b_amount_second decimal(15,5) DEFAULT NULL,
  c_type_first varchar(256) DEFAULT NULL,
  c_from_first varchar(256) DEFAULT NULL,
  c_amount_first decimal(15,5) DEFAULT NULL,
  c_operator varchar(256) DEFAULT NULL,
  c_type_second varchar(256) DEFAULT NULL,
  c_from_second varchar(256) DEFAULT NULL,
  c_amount_second decimal(15,5) DEFAULT NULL,
  d_type_first varchar(256) DEFAULT NULL,
  d_from_first varchar(256) DEFAULT NULL,
  d_amount_first decimal(15,5) DEFAULT NULL,
  d_operator varchar(256) DEFAULT NULL,
  d_type_second varchar(256) DEFAULT NULL,
  d_from_second varchar(256) DEFAULT NULL,
  d_amount_second decimal(15,5) DEFAULT NULL,
  e_type_first varchar(256) DEFAULT NULL,
  e_from_first varchar(256) DEFAULT NULL,
  e_amount_first decimal(15,5) DEFAULT NULL,
  e_operator varchar(256) DEFAULT NULL,
  e_type_second varchar(256) DEFAULT NULL,
  e_from_second varchar(256) DEFAULT NULL,
  e_amount_second decimal(15,5) DEFAULT NULL,
  f_type_first varchar(256) DEFAULT NULL,
  f_from_first varchar(256) DEFAULT NULL,
  f_amount_first decimal(15,5) DEFAULT NULL,
  f_operator varchar(256) DEFAULT NULL,
  f_type_second varchar(256) DEFAULT NULL,
  f_from_second varchar(256) DEFAULT NULL,
  f_amount_second decimal(15,5) DEFAULT NULL,
  g_type_first varchar(256) DEFAULT NULL,
  g_from_first varchar(256) DEFAULT NULL,
  g_amount_first decimal(15,5) DEFAULT NULL,
  g_operator varchar(256) DEFAULT NULL,
  g_type_second varchar(256) DEFAULT NULL,
  g_from_second varchar(256) DEFAULT NULL,
  g_amount_second decimal(15,5) DEFAULT NULL,
  h_type_first varchar(256) DEFAULT NULL,
  h_from_first varchar(256) DEFAULT NULL,
  h_amount_first decimal(15,5) DEFAULT NULL,
  h_operator varchar(256) DEFAULT NULL,
  h_type_second varchar(256) DEFAULT NULL,
  h_from_second varchar(256) DEFAULT NULL,
  h_amount_second decimal(15,5) DEFAULT NULL,
  i_type_first varchar(256) DEFAULT NULL,
  i_from_first varchar(256) DEFAULT NULL,
  i_amount_first decimal(15,5) DEFAULT NULL,
  i_operator varchar(256) DEFAULT NULL,
  i_type_second varchar(256) DEFAULT NULL,
  i_from_second varchar(256) DEFAULT NULL,
  i_amount_second decimal(15,5) DEFAULT NULL,
  j_type_first varchar(256) DEFAULT NULL,
  j_from_first varchar(256) DEFAULT NULL,
  j_amount_first decimal(15,5) DEFAULT NULL,
  j_operator varchar(256) DEFAULT NULL,
  j_type_second varchar(256) DEFAULT NULL,
  j_from_second varchar(256) DEFAULT NULL,
  j_amount_second decimal(15,5) DEFAULT NULL,
  k_type_first varchar(256) DEFAULT NULL,
  k_from_first varchar(256) DEFAULT NULL,
  k_amount_first decimal(15,5) DEFAULT NULL,
  k_operator varchar(256) DEFAULT NULL,
  k_type_second varchar(256) DEFAULT NULL,
  k_from_second varchar(256) DEFAULT NULL,
  k_amount_second decimal(15,5) DEFAULT NULL,
  l_type_first varchar(256) DEFAULT NULL,
  l_from_first varchar(256) DEFAULT NULL,
  l_amount_first decimal(15,5) DEFAULT NULL,
  l_operator varchar(256) DEFAULT NULL,
  l_type_second varchar(256) DEFAULT NULL,
  l_from_second varchar(256) DEFAULT NULL,
  l_amount_second decimal(15,5) DEFAULT NULL,
  m_type_first varchar(256) DEFAULT NULL,
  m_from_first varchar(256) DEFAULT NULL,
  m_amount_first decimal(15,5) DEFAULT NULL,
  m_operator varchar(256) DEFAULT NULL,
  m_type_second varchar(256) DEFAULT NULL,
  m_from_second varchar(256) DEFAULT NULL,
  m_amount_second decimal(15,5) DEFAULT NULL,
  n_type_first varchar(256) DEFAULT NULL,
  n_from_first varchar(256) DEFAULT NULL,
  n_amount_first decimal(15,5) DEFAULT NULL,
  n_operator varchar(256) DEFAULT NULL,
  n_type_second varchar(256) DEFAULT NULL,
  n_from_second varchar(256) DEFAULT NULL,
  n_amount_second decimal(15,5) DEFAULT NULL,
  o_type_first varchar(256) DEFAULT NULL,
  o_from_first varchar(256) DEFAULT NULL,
  o_amount_first decimal(15,5) DEFAULT NULL,
  o_operator varchar(256) DEFAULT NULL,
  o_type_second varchar(256) DEFAULT NULL,
  o_from_second varchar(256) DEFAULT NULL,
  o_amount_second decimal(15,5) DEFAULT NULL,
  PRIMARY KEY (fee_tier_id)
);

CREATE INDEX fee_tier_idx01 ON payment_dev.fee_tier (service_command_id);

CREATE TABLE IF NOT EXISTS payment_dev.m_action_type (
  action_type_id BIGSERIAL,
  action_type varchar(256) NOT NULL,
  PRIMARY KEY (action_type_id)
);

CREATE UNIQUE INDEX action_type ON payment_dev.m_action_type (action_type);

CREATE TABLE IF NOT EXISTS payment_dev.m_actor_type (
  actor_type_id BIGSERIAL,
  actor_type varchar(256) NOT NULL,
  PRIMARY KEY (actor_type_id)
);

CREATE UNIQUE INDEX actor_type ON payment_dev.m_actor_type (actor_type);

CREATE TABLE IF NOT EXISTS payment_dev.m_amount_type (
  amount_type_id BIGSERIAL,
  amount_type varchar(256) NOT NULL,
  PRIMARY KEY (amount_type_id)
);

CREATE UNIQUE INDEX amount_type ON payment_dev.m_amount_type (amount_type);

CREATE TABLE IF NOT EXISTS payment_dev.m_command (
  command_id BIGSERIAL,
  command_name varchar(256) NOT NULL,
  PRIMARY KEY (command_id)
);

CREATE UNIQUE INDEX command_name ON payment_dev.m_command (command_name);

CREATE TABLE IF NOT EXISTS payment_dev.m_fee_tier_condition (
  fee_tier_condition_id BIGSERIAL,
  fee_tier_condition varchar(256) NOT NULL,
  PRIMARY KEY (fee_tier_condition_id)
);

CREATE UNIQUE INDEX fee_tier_condition ON payment_dev.m_fee_tier_condition (fee_tier_condition);

CREATE TABLE IF NOT EXISTS payment_dev.m_payment_method (
  payment_method_id BIGSERIAL,
  payment_method varchar(256) NOT NULL,
  PRIMARY KEY (payment_method_id)
);

CREATE UNIQUE INDEX payment_method ON payment_dev.m_payment_method (payment_method);

CREATE TABLE IF NOT EXISTS payment_dev.m_security_type (
  id BIGSERIAL,
  name varchar(256) NOT NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX name ON payment_dev.m_security_type (name);

CREATE TABLE IF NOT EXISTS payment_dev.m_sof_type (
  sof_type_id BIGSERIAL,
  sof_type varchar(256) NOT NULL,
  PRIMARY KEY (sof_type_id)
);

CREATE UNIQUE INDEX sof_type ON payment_dev.m_sof_type (sof_type);

CREATE TABLE IF NOT EXISTS payment_dev.m_spi_url_call_method (
  spi_url_call_method_id BIGSERIAL,
  spi_url_call_method varchar(100) NOT NULL,
  PRIMARY KEY (spi_url_call_method_id)
);

CREATE UNIQUE INDEX spi_url_call_method ON payment_dev.m_spi_url_call_method (spi_url_call_method);

CREATE TABLE IF NOT EXISTS payment_dev.m_spi_url_configuration_type (
  spi_url_configuration_type_id BIGSERIAL,
  spi_url_configuration_type varchar(100) NOT NULL,
  PRIMARY KEY (spi_url_configuration_type_id)
);

CREATE UNIQUE INDEX spi_url_configuration_type ON payment_dev.m_spi_url_configuration_type (spi_url_configuration_type);

CREATE TABLE IF NOT EXISTS payment_dev.m_spi_url_type (
  spi_url_type_id BIGSERIAL,
  spi_url_type varchar(100) NOT NULL,
  PRIMARY KEY (spi_url_type_id)
);

CREATE UNIQUE INDEX spi_url_type ON payment_dev.m_spi_url_type (spi_url_type);

CREATE TABLE IF NOT EXISTS payment_dev.order_balance_movement (
  order_balance_movement_id varchar(256) NOT NULL,
  order_id varchar(256) NOT NULL,
  action_type varchar(256) NOT NULL,
  actor_user_id BIGINT DEFAULT NULL,
  sof_id BIGINT NOT NULL,
  sof_type_id BIGINT NOT NULL,
  amount decimal(20,5) NOT NULL,
  status SMALLINT NOT NULL DEFAULT '0',
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  fee_related SMALLINT DEFAULT '0',
  remark varchar(256) DEFAULT NULL,
  user_id BIGINT DEFAULT NULL,
  user_type_id BIGINT DEFAULT NULL,
  amount_type varchar(256) DEFAULT NULL,
  post_balance decimal(20,5) DEFAULT NULL,
  pre_balance decimal(20,5) DEFAULT NULL,
  short_order_id varchar(256) DEFAULT NULL,
  PRIMARY KEY (order_balance_movement_id)
);

CREATE  INDEX order_balance_movement_idx01 ON payment_dev.order_balance_movement (order_id);
CREATE  INDEX order_balance_movement_idx02 ON payment_dev.order_balance_movement (short_order_id);

CREATE TABLE IF NOT EXISTS payment_dev.order_reference (
  order_reference_id varchar(256) NOT NULL,
  order_id varchar(256) DEFAULT NULL,
  key varchar(1024) NOT NULL,
  value varchar(1024) DEFAULT NULL,
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (order_reference_id)
);

CREATE  INDEX order_idx01 ON payment_dev.order_reference (order_id);

CREATE TABLE IF NOT EXISTS payment_dev.service (
  service_id BIGSERIAL,
  service_name varchar(256) NOT NULL,
  service_group_id BIGINT NOT NULL,
  currency varchar(3) NOT NULL,
  status SMALLINT NOT NULL DEFAULT '1',
  description varchar(256) DEFAULT NULL,
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  image_url varchar(1024) DEFAULT NULL,
  display_name varchar(256) DEFAULT NULL,
  display_name_local varchar(256) DEFAULT NULL,
  apply_to_all_agent_type SMALLINT NOT NULL DEFAULT '0',
  PRIMARY KEY (service_id)
);

CREATE  INDEX service_idx01 ON payment_dev.service  (service_name);
CREATE  INDEX service_idx02 ON payment_dev.service  (service_name,service_group_id,currency);

CREATE TABLE IF NOT EXISTS payment_dev.service_agent_type (
  id BIGSERIAL,
  service_id BIGINT NOT NULL,
  agent_type_id BIGINT NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT service_agent_type_fk01 FOREIGN KEY (service_id) REFERENCES payment_dev.service (service_id)
);

CREATE TABLE IF NOT EXISTS payment_dev.service_command (
  service_command_id BIGSERIAL,
  service_id BIGINT NOT NULL,
  command_id BIGINT NOT NULL,
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (service_command_id)
);

CREATE  INDEX service_command_idx01 ON payment_dev.service_command  (command_id,service_id);

CREATE TABLE IF NOT EXISTS payment_dev.service_group (
  service_group_id BIGSERIAL,
  service_group_name varchar(256) NOT NULL,
  description varchar(256) DEFAULT NULL,
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  image_url varchar(1024) DEFAULT NULL,
  display_name varchar(256) DEFAULT NULL,
  display_name_local varchar(256) DEFAULT NULL,
  PRIMARY KEY (service_group_id)
);

CREATE  INDEX service_group_idx01 ON payment_dev.service_group (service_group_name);

CREATE TABLE IF NOT EXISTS payment_dev.spi_url (
  spi_url_id BIGSERIAL,
  service_command_id BIGINT NOT NULL,
  read_timeout BIGINT DEFAULT NULL,
  spi_url_type varchar(100) NOT NULL,
  url varchar(256) DEFAULT NULL,
  spi_url_call_method varchar(50) NOT NULL,
  expire_in_minute NUMERIC(3) NOT NULL,
  max_retry NUMERIC(3) NOT NULL DEFAULT '1',
  retry_delay_millisecond BIGINT NOT NULL,
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (spi_url_id)
);

CREATE INDEX spi_url_idx01 ON payment_dev.spi_url (service_command_id);
CREATE UNIQUE INDEX service_command_id ON payment_dev.spi_url (service_command_id,spi_url_type);

CREATE TABLE IF NOT EXISTS payment_dev.spi_url_configuration (
  spi_url_configuration_id BIGSERIAL,
  spi_url_id BIGINT NOT NULL,
  spi_url_configuration_type varchar(100) NOT NULL,
  read_timeout BIGINT DEFAULT NULL,
  url varchar(256) DEFAULT NULL,
  expire_in_minute BIGINT NOT NULL,
  max_retry NUMERIC(3) DEFAULT '1',
  retry_delay_millisecond BIGINT DEFAULT NULL,
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (spi_url_configuration_id)
);

CREATE INDEX spi_url_configuration_idx01 ON payment_dev.spi_url_configuration (spi_url_id);
CREATE UNIQUE INDEX spi_url_id ON payment_dev.spi_url_configuration (spi_url_id,spi_url_configuration_type);

CREATE TABLE IF NOT EXISTS payment_dev.tier_level (
  id BIGSERIAL,
  name varchar(256) NOT NULL,
  label varchar(256) NOT NULL,
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX name_tier ON payment_dev.tier_level (name); 
CREATE UNIQUE INDEX label ON payment_dev.tier_level (label);

CREATE TABLE IF NOT EXISTS payment_dev.tr_order (
  order_id varchar(256) NOT NULL,
  ext_transaction_id varchar(256) DEFAULT NULL,
  payment_method_name varchar(256) DEFAULT NULL,
  payment_method_ref varchar(256) DEFAULT NULL,
  service_id BIGINT DEFAULT NULL,
  service_name varchar(256) DEFAULT NULL,
  command_id BIGINT DEFAULT NULL,
  command_name varchar(256) DEFAULT NULL,
  service_command_id BIGINT NOT NULL,
  initiator_user_id BIGINT NOT NULL,
  initiator_user_type varchar(256) NOT NULL,
  initiator_sof_id BIGINT DEFAULT NULL,
  initiator_sof_type_id BIGINT DEFAULT NULL,
  payer_user_id BIGINT NOT NULL,
  payer_user_type varchar(256) NOT NULL,
  payer_user_ref_type varchar(256) DEFAULT NULL,
  payer_user_ref_value varchar(256) DEFAULT NULL,
  payer_sof_id BIGINT NOT NULL,
  payer_sof_type_id BIGINT NOT NULL,
  payee_user_id BIGINT NOT NULL,
  payee_user_type varchar(256) NOT NULL,
  payee_user_ref_type varchar(256) DEFAULT NULL,
  payee_user_ref_value varchar(256) DEFAULT NULL,
  payee_sof_id BIGINT NOT NULL,
  payee_sof_type_id BIGINT NOT NULL,
  currency varchar(3) NOT NULL,
  ref_order_id varchar(256) DEFAULT NULL,
  amount decimal(20,5) NOT NULL,
  fee decimal(20,5) NOT NULL DEFAULT '0.00000',
  bonus decimal(20,5) NOT NULL DEFAULT '0.00000',
  settlement_amount decimal(20,5) NOT NULL,
  product_name varchar(256) DEFAULT NULL,
  product_ref1 varchar(1024) DEFAULT NULL,
  product_ref2 varchar(1024) DEFAULT NULL,
  product_ref3 varchar(1024) DEFAULT NULL,
  product_ref4 varchar(1024) DEFAULT NULL,
  product_ref5 varchar(1024) DEFAULT NULL,
  state varchar(256) DEFAULT NULL,
  status SMALLINT NOT NULL DEFAULT '0',
  notification_status SMALLINT DEFAULT NULL,
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  created_client_id varchar(32) DEFAULT NULL,
  executed_client_id varchar(32) DEFAULT NULL,
  security_ref varchar(256) DEFAULT NULL,
  security_type_id SMALLINT DEFAULT NULL,
  error_code varchar(100) DEFAULT NULL,
  error_message varchar(256) DEFAULT NULL,
  a decimal(20,5) DEFAULT '0.00000',
  b decimal(20,5) DEFAULT '0.00000',
  c decimal(20,5) DEFAULT '0.00000',
  d decimal(20,5) DEFAULT '0.00000',
  e decimal(20,5) DEFAULT '0.00000',
  f decimal(20,5) DEFAULT '0.00000',
  g decimal(20,5) DEFAULT '0.00000',
  h decimal(20,5) DEFAULT '0.00000',
  i decimal(20,5) DEFAULT '0.00000',
  j decimal(20,5) DEFAULT '0.00000',
  k decimal(20,5) DEFAULT '0.00000',
  l decimal(20,5) DEFAULT '0.00000',
  m decimal(20,5) DEFAULT '0.00000',
  n decimal(20,5) DEFAULT '0.00000',
  o decimal(20,5) DEFAULT '0.00000',
  created_channel_type varchar(256) DEFAULT NULL,
  created_device_unique_reference varchar(256) DEFAULT NULL,
  short_order_id varchar(256) DEFAULT NULL,
  wait_delay_timestamp timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (order_id)
);

CREATE UNIQUE INDEX short_order_id ON payment_dev.tr_order (short_order_id);
CREATE INDEX tr_order_idx01 ON payment_dev.tr_order (order_id,status);
CREATE INDEX tr_order_idx02 ON payment_dev.tr_order (order_id,state);
CREATE INDEX tr_order_idx03 ON payment_dev.tr_order (payee_user_id,payee_user_type);
CREATE INDEX tr_order_idx04 ON payment_dev.tr_order (initiator_user_id);
CREATE INDEX tr_order_idx05 ON payment_dev.tr_order (payer_user_id);
CREATE INDEX tr_order_idx06 ON payment_dev.tr_order (payee_user_id);
CREATE INDEX tr_order_idx07 ON payment_dev.tr_order (initiator_user_id,initiator_user_type);
CREATE INDEX tr_order_idx08 ON payment_dev.tr_order (payer_user_id,payer_user_type);
CREATE INDEX tr_order_idx09 ON payment_dev.tr_order (currency);
CREATE INDEX tr_order_idx10 ON payment_dev.tr_order (ext_transaction_id);
CREATE INDEX tr_order_idx11 ON payment_dev.tr_order (ref_order_id);
CREATE INDEX tr_order_idx12 ON payment_dev.tr_order (short_order_id);

CREATE TABLE IF NOT EXISTS payment_dev.tr_transaction (
  transaction_id varchar(256) NOT NULL,
  service_group_id BIGINT DEFAULT NULL,
  service_id BIGINT DEFAULT NULL,
  service_command_id BIGINT DEFAULT NULL,
  order_id varchar(256) DEFAULT NULL,
  sof_type varchar(256) DEFAULT NULL,
  status SMALLINT DEFAULT NULL,
  start_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  end_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (transaction_id)
);

CREATE TABLE IF NOT EXISTS payment_dev.user_payment_pin (
  id BIGSERIAL,
  user_id BIGINT DEFAULT NULL,
  user_type_id BIGINT DEFAULT NULL,
  pin varchar(256) DEFAULT NULL,
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX user_id ON payment_dev.user_payment_pin (user_id,user_type_id);
CREATE INDEX user_payment_pin_idx01 ON payment_dev.user_payment_pin (user_id,user_type_id);

CREATE TABLE IF NOT EXISTS payment_dev.user_sof (
  id BIGSERIAL,
  user_id BIGINT DEFAULT NULL,
  user_type_id BIGINT DEFAULT NULL,
  sof_id BIGINT DEFAULT NULL,
  sof_type_id BIGINT DEFAULT NULL,
  currency varchar(3) DEFAULT NULL,
  is_deleted SMALLINT NOT NULL DEFAULT '0',
  created_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  last_updated_timestamp timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id)
);

CREATE INDEX user_sof_idx01 ON payment_dev.user_sof (user_id,user_type_id,sof_type_id,currency);
CREATE INDEX user_sof_idx02 ON payment_dev.user_sof (user_id,user_type_id,currency);
CREATE INDEX user_sof_idx03 ON payment_dev.user_sof (user_id,user_type_id,currency);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

DELETE IGNORE FROM mysql.user WHERE User='#DB_RW_USERNAME_PAYMENT#';
DELETE IGNORE FROM mysql.user WHERE User='#DB_RO_USERNAME_PAYMENT#';

DROP TABLE IF EXISTS payment_dev.agent_bonus_distribution;
DROP TABLE IF EXISTS payment_dev.agent_fee_distribution;
DROP TABLE IF EXISTS payment_dev.balance_distribution;
DROP TABLE IF EXISTS payment_dev.bonus_distribution;
DROP TABLE IF EXISTS payment_dev.fee_tier;
DROP TABLE IF EXISTS payment_dev.m_action_type;
DROP TABLE IF EXISTS payment_dev.m_actor_type;
DROP TABLE IF EXISTS payment_dev.m_amount_type;
DROP TABLE IF EXISTS payment_dev.m_command;
DROP TABLE IF EXISTS payment_dev.m_fee_tier_condition;
DROP TABLE IF EXISTS payment_dev.m_payment_method;
DROP TABLE IF EXISTS payment_dev.m_security_type;
DROP TABLE IF EXISTS payment_dev.m_sof_type;
DROP TABLE IF EXISTS payment_dev.m_spi_url_call_method;
DROP TABLE IF EXISTS payment_dev.m_spi_url_configuration_type;
DROP TABLE IF EXISTS payment_dev.m_spi_url_type;
DROP TABLE IF EXISTS payment_dev.order_balance_movement;
DROP TABLE IF EXISTS payment_dev.order_reference;
DROP TABLE IF EXISTS payment_dev.service_agent_type;
DROP TABLE IF EXISTS payment_dev.service;
DROP TABLE IF EXISTS payment_dev.service_command;
DROP TABLE IF EXISTS payment_dev.service_group;
DROP TABLE IF EXISTS payment_dev.spi_url;
DROP TABLE IF EXISTS payment_dev.spi_url_configuration;
DROP TABLE IF EXISTS payment_dev.tier_level;
DROP TABLE IF EXISTS payment_dev.tr_order;
DROP TABLE IF EXISTS payment_dev.tr_transaction;
DROP TABLE IF EXISTS payment_dev.user_payment_pin;
DROP TABLE IF EXISTS payment_dev.user_sof;