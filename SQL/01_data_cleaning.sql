=========================================================
Project  : Pizza Sales Analysis
File     : 01_data_cleaning.sql
Author   : Ricky Christian Simatupang
Database : PostgreSQL
=========================================================
Description:
This script performs data cleaning and data preparation
before analysis.
=========================================================
---------------------------------------------------------
---STEP 1: Change Data Types
---------------------------------------------------------

---------------------------------------------------------
---dqpizza.master_customer
---------------------------------------------------------
ALTER TABLE dqpizza.master_customer
	ALTER COLUMN birth_date TYPE DATE
		USING birth_date::DATE,
	ALTER COLUMN open_date TYPE DATE
		USING open_date::DATE,
	ALTER COLUMN created_date TYPE DATE
		USING created_date::DATE;

---------------------------------------------------------
---dqpizza.master_pizza		
---------------------------------------------------------
ALTER TABLE dqpizza.master_pizza
	ALTER COLUMN price TYPE INT
		USING price::INT,
	ALTER COLUMN production_cost TYPE INT
		USING production_cost::INT,
	ALTER COLUMN created_date TYPE DATE
		USING created_date::DATE;

---------------------------------------------------------
---dqpizza.master_pizza_type
---------------------------------------------------------
ALTER TABLE dqpizza.master_pizza_type
	ALTER COLUMN created_date TYPE DATE
		USING created_date::DATE;

---------------------------------------------------------
---dqpizza.transaction_order
---------------------------------------------------------
ALTER TABLE dqpizza.transaction_order
	ALTER COLUMN order_date TYPE DATE
		USING order_date::DATE,
	ALTER COLUMN order_time TYPE TIME
		USING order_time::TIME,
	ALTER COLUMN completion_time TYPE TIME
		USING completion_time::TIME,
	ALTER COLUMN created_date TYPE TIME
		USING created_date::TIME;

---------------------------------------------------------
---dqpizza.transaction_order_detail
---------------------------------------------------------
ALTER TABLE dqpizza.transaction_order_detail
	ALTER COLUMN quantity TYPE INT
		USING quantity::INT,
	ALTER COLUMN created_date TYPE TIME
		USING created_date::TIME;

---------------------------------------------------------
---STEP 2: Add Primary Keys
---------------------------------------------------------
---dqpizza.master_customer
ALTER TABLE dqpizza.master_customer
ADD CONSTRAINT pk_master_customer
PRIMARY KEY (customer_id);

---dqpizza.master_pizza
ALTER TABLE dqpizza.master_pizza
ADD CONSTRAINT pk_master_pizza
PRIMARY KEY (pizza_id);

---dqpizza.master_pizza_type
ALTER TABLE dqpizza.master_pizza_type
ADD CONSTRAINT pk_master_pizza_type
PRIMARY KEY (pizza_type_id);

---dqpizza.transaction_order
ALTER TABLE dqpizza.transaction_order
ADD CONSTRAINT pk_transaction_order
PRIMARY KEY (order_id);

---dqpizza.transation_order_detail
ALTER TABLE dqpizza.transaction_order_detail
ADD CONSTRAINT pk_transaction_order_detail
PRIMARY KEY(order_details_id);

---------------------------------------------------------
---STEP 3: Add Foreign Keys
---------------------------------------------------------
-- transaction_order -> master_customer
ALTER TABLE dqpizza.transaction_order
ADD CONSTRAINT fk_transaction_order_customer
FOREIGN KEY (customer_id)
REFERENCES dqpizza.master_customer(customer_id);

-- transaction_order_detail -> transaction_order
ALTER TABLE dqpizza.transaction_order_detail
ADD CONSTRAINT fk_order_detail_order
FOREIGN KEY (order_id)
REFERENCES dqpizza.transaction_order(order_id);

-- transaction_order_detail -> master_pizza
ALTER TABLE dqpizza.transaction_order_detail
ADD CONSTRAINT fk_order_detail_pizza
FOREIGN KEY (pizza_id)
REFERENCES dqpizza.master_pizza(pizza_id);

-- master_pizza -> master_pizza_type
ALTER TABLE dqpizza.master_pizza
ADD CONSTRAINT fk_master_pizza_type
FOREIGN KEY (pizza_type_id)
REFERENCES dqpizza.master_pizza_type(pizza_type_id);