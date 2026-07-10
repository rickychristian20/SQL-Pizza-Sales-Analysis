=========================================================
Project  : Pizza Sales Analysis
File     : 02_data_validation.sql
Author   : Ricky Christian Simatupang
Database : PostgreSQL
=========================================================
Description:
This script performs data validation

---- Check duplicate customer_id
SELECT 
	customer_id, 
	COUNT(*)
FROM dqpizza.master_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

---- Check duplicate order_id
SELECT
order_id,
COUNT(*)
FROM dqpizza.transaction_order
GROUP BY order_id
HAVING COUNT(*) > 1;

---- Check NULL
SELECT 
	*
FROM dqpizza.master_customer
WHERE customer_id IS NULL ;

SELECT
	*
FROM dqpizza.master_pizza
WHERE pizza_id IS NULL ;

SELECT
	*
FROM dqpizza.master_pizza_type
WHERE pizza_type_id IS NULL ;
