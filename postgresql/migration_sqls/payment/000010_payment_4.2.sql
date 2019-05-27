-- +goose Up
-- SQL in this section is executed when the migration is applied.
USE payment_dev;

ALTER TABLE payment_dev.service_limitation DROP COLUMN current_value;
ALTER TABLE payment_dev.service_limitation_condition ADD current_value DECIMAL(20, 5) NOT NULL;

CREATE OR REPLACE VIEW payment_dev.service_limitation_detail AS
 	SELECT 
 		sl.id AS id, 
 		sl.service_id AS service_id, 
 		s.service_name AS service_name,
 		s.currency AS currency, 
 		sl.limitation_type AS limitation_type, 
 		sl.equation_id AS equation_id, 
 		sl.limitation_value AS limitation_value, 
 		sl.reset_time_block_value AS reset_time_block_value, 
 		sl.reset_time_block_unit AS reset_time_block_unit, 
 		sl.is_deleted AS is_deleted, 
 		sl.next_reset_timestamp AS next_reset_timestamp, 
 		sl.start_effective_timestamp AS start_effective_timestamp, 
 		sl.end_effective_timestamp AS end_effective_timestamp, 
 		sl.created_timestamp AS created_timestamp, 
 		sl.last_updated_timestamp AS last_updated_timestamp
	FROM payment_dev.service_limitation AS sl, payment_dev.service AS s
	WHERE sl.service_id = s.service_id;
-- CREATE OR REPLACE VIEW payment_dev.service_limitation_condition_detail AS
--  	SELECT
-- 	    slc.id AS id,
-- 	    slc.service_limitation_id AS service_limitation_id,
-- 	    slc.current_value AS current_value,
-- 	    slc.actor AS actor,
-- 	    slc.actor_user_type AS actor_user_type,
-- 	    slc.actor_type_id AS actor_type_id,
-- 	    CASE
-- 	    	WHEN (slc.actor_user_type = 'agent' and slc.actor_type_id is not null) THEN (SELECT `name` FROM agent_dev.agent_type WHERE id = slc.actor_type_id)
-- 	    	ELSE null
-- 	    END AS actor_type_name,
-- 	    slc.actor_classification_id AS actor_classification_id,
-- 	    CASE
-- 	    	WHEN (slc.actor_user_type = 'agent' and slc.actor_classification_id is not null)  THEN (SELECT `name` FROM agent_dev.agent_classification WHERE id = slc.actor_classification_id)
-- 	    	WHEN (slc.actor_user_type = 'customer' and slc.actor_classification_id is not null) THEN (SELECT `name` FROM customer_dev.customer_classification WHERE id = slc.actor_classification_id) 
-- 	    	ELSE null
-- 	    END AS actor_classification_name,
-- 	    slc.is_deleted AS is_deleted,
-- 	    slc.created_timestamp AS created_timestamp,
-- 	    slc.last_updated_timestamp AS last_updated_timestamp
-- 	FROM payment_dev.service_limitation_condition AS slc;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
DROP VIEW IF EXISTS payment_dev.service_limitation_condition_detail;
DROP VIEW IF EXISTS payment_dev.service_limitation_detail;
ALTER TABLE payment_dev.service_limitation_condition DROP COLUMN current_value;
ALTER TABLE payment_dev.service_limitation ADD current_value DECIMAL(20, 5) NOT NULL;