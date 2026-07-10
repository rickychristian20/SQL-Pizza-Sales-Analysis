=================================================
Exploratory Data Analysis (EDA)
Project  : DQPizza Sales Analysis
Author   : Ricky Christian
Database : PostgreSQL
Dataset  : DQPizza
Purpose  : Analyze sales performance, customer behavior,
           and product performance using SQL.
=================================================

---------------------------------------------
1. KPI 
---------------------------------------------

--- Total transaction
SELECT
	COUNT(*) total_order
FROM dqpizza.transaction_order;

--- Total Customers
SELECT
	COUNT(*) total_customer
FROM dqpizza.master_customer;

--- Total quantity
SELECT
	SUM(quantity) 
FROM dqpizza.transaction_order_detail;

--- Total Revenue
SELECT
    SUM(mp.price * tod.quantity) total_revenue
FROM dqpizza.transaction_order_detail tod
JOIN dqpizza.master_pizza mp
    ON tod.pizza_id = mp.pizza_id;
	
---Total Profit
SELECT
    SUM(
        (mp.price - mp.production_cost) * tod.quantity
    ) total_profit
FROM dqpizza.transaction_order_detail tod
JOIN dqpizza.master_pizza mp
    ON tod.pizza_id = mp.pizza_id;

---------------------------------------------
2. DATE ANALYSIS
---------------------------------------------

--- Total Transaction by Day
SELECT
	TO_CHAR(order_date,'Day') Days_name,
	COUNT(*) total_transaction
FROM dqpizza.transaction_order
GROUP BY TO_CHAR(order_date,'Day'), 
		EXTRACT(ISODOW FROM order_date)
ORDER BY EXTRACT(ISODOW FROM order_date);

--- Total Transaction by Month
SELECT
	TO_CHAR(order_date,'Month') month_name,
	COUNT(*) total_transaction
FROM dqpizza.transaction_order
GROUP BY TO_CHAR(order_date,'Month'), EXTRACT(MONTH FROM order_date)
ORDER BY EXTRACT(MONTH FROM order_date);

--- Total Transaction by Quarter
SELECT
	EXTRACT(QUARTER FROM order_date) By_Quarter,
	COUNT(*) total_transaction
FROM dqpizza.transaction_order
GROUP BY EXTRACT(QUARTER FROM order_date)
ORDER BY EXTRACT(QUARTER FROM order_date);

-- Total Transaction by Year

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    COUNT(*) AS total_transactions
FROM dqpizza.transaction_order
GROUP BY 1
ORDER BY 1;

---------------------------------------------
3. CUSTOMERS ANALYSIS
---------------------------------------------

--- New vs Repeat Customers
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) first_order_date
    FROM dqpizza.transaction_order
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN t.order_date = f.first_order_date THEN 'New_Customer'
        ELSE 'Repeat_Customer'
    END AS customer_type,
    COUNT(t.order_id) total_orders
FROM dqpizza.transaction_order t
JOIN first_orders f ON t.customer_id = f.customer_id
GROUP BY 1;

--- Top 10 Customer By Transaction
SELECT
	m.customer_id,
	m.customer_name,
	COUNT(o.order_id) total_transaction
FROM dqpizza.master_customer m
LEFT JOIN dqpizza.transaction_order o
	ON m.customer_id = o.customer_id
GROUP BY m.customer_id, m.customer_name
ORDER BY COUNT(order_id) DESC
LIMIT 10;

--- Top 10 Customer By Revenue
WITH total_revenue AS (
	SELECT
		customer_id,
		SUM(tod.quantity*mp.price) revenue
	FROM dqpizza.transaction_order_detail tod
	JOIN dqpizza.master_pizza mp
		ON tod.pizza_id = mp.pizza_id
	JOIN dqpizza.transaction_order o
		ON o.order_id = tod.order_id
	GROUP BY customer_id
)
SELECT
	r.customer_id,
	m.customer_name,
	revenue
FROM dqpizza.master_customer m
JOIN total_revenue r
	ON r.customer_id = m.customer_id
ORDER BY revenue DESC 
LIMIT 10; 

---------------------------------------------
4. SALES ANALYSIS
---------------------------------------------

--- Revenue & Profit By Month
WITH revenue AS (
	SELECT
		tod.order_id,
		SUM(mp.price*tod.quantity) total_revenue,
		SUM((mp.price - mp.production_cost) * tod.quantity) profit
	FROM dqpizza.master_pizza mp
	JOIN dqpizza.transaction_order_detail tod
		ON mp.pizza_id = tod.pizza_id
	GROUP BY tod.order_id;
)

SELECT
	TO_CHAR(o.order_date,'Month') month_name,
	SUM(tr.total_revenue) revenue_by_Month,
	SUM(profit) profit
FROM dqpizza.transaction_order o
JOIN revenue tr
	ON o.order_id = tr.order_id
GROUP BY TO_CHAR(order_date,'Month'), EXTRACT(MONTH FROM order_date)
ORDER BY EXTRACT(MONTH FROM order_date);

--- Revenue & Profit By Days
WITH revenue AS (
	SELECT
		tod.order_id,
		SUM(mp.price*tod.quantity) total_revenue,
		SUM((mp.price - mp.production_cost) * tod.quantity) profit
	FROM dqpizza.master_pizza mp
	JOIN dqpizza.transaction_order_detail tod
		ON mp.pizza_id = tod.pizza_id
	GROUP BY tod.order_id,mp.production_cost
)

SELECT
	TO_CHAR(o.order_date,'Day') Days_name,
	SUM(tr.total_revenue) revenue_by_Month,
	SUM(profit) profit
FROM dqpizza.transaction_order o
JOIN revenue tr
	ON o.order_id = tr.order_id
GROUP BY TO_CHAR(order_date,'Day'), 
		EXTRACT(ISODOW FROM order_date)
ORDER BY EXTRACT(ISODOW FROM order_date);

---------------------------------------------
5. Product ANALYSIS
---------------------------------------------

--- Revenue & Profit By Pizza Size
	SELECT
		mp.size,
		SUM(mp.price*tod.quantity) total_revenue,
		SUM((mp.price - mp.production_cost) * tod.quantity) profit
	FROM dqpizza.master_pizza mp
	JOIN dqpizza.transaction_order_detail tod
		ON mp.pizza_id = tod.pizza_id
	GROUP BY mp.size

--- Revenue & Profit By Pizza Category
WITH pizza_type AS (
	SELECT
		mp.pizza_type_id,
		COUNT(order_id) total_transaction,
		SUM(mp.price*tod.quantity) total_revenue,
		SUM((mp.price - mp.production_cost) * tod.quantity) profit
	FROM dqpizza.master_pizza mp
	JOIN dqpizza.transaction_order_detail tod
		ON mp.pizza_id = tod.pizza_id
	GROUP BY mp.pizza_type_id
)

SELECT
UPPER(category) kategori_pizza,
SUM(total_revenue) revenue,
SUM(profit) profit
FROM dqpizza.master_pizza_type mtp
JOIN pizza_type mp
	ON mp.pizza_type_id = mtp.pizza_type_id
GROUP BY 1

--- TOP 10 Revenue & Profit By Pizza Name
WITH pizza_type AS (
	SELECT
		mp.pizza_type_id,
		COUNT(order_id) total_transaction,
		SUM(mp.price*tod.quantity) total_revenue,
		SUM((mp.price - mp.production_cost) * tod.quantity) profit
	FROM dqpizza.master_pizza mp
	JOIN dqpizza.transaction_order_detail tod
		ON mp.pizza_id = tod.pizza_id
	GROUP BY mp.pizza_type_id
)

SELECT
name,
SUM(total_revenue) revenue,
SUM(profit) profit
FROM dqpizza.master_pizza_type mtp
JOIN pizza_type mp
	ON mp.pizza_type_id = mtp.pizza_type_id
GROUP BY 1
ORDER BY revenue DESC 
LIMIT 10 ;

--- TOP 10 Selling Pizza Name
WITH pizza_name AS (
	SELECT
		mpt.name,
		mp.pizza_id
	FROM dqpizza.master_pizza_type mpt
	JOIN dqpizza.master_pizza mp
		ON mpt.pizza_type_id = mp.pizza_type_id
)
SELECT 
	mpt.name pizza_name,
	SUM(tod.quantity) quantity
FROM pizza_name mpt
JOIN dqpizza.transaction_order_detail tod
	ON mpt.pizza_id = tod.pizza_id
GROUP BY 1
ORDER BY quantity DESC
LIMIT 10;
 