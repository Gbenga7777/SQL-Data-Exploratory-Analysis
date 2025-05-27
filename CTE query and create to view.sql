CREATE VIEW gold.product_reports AS --Creating a view table
WITH base_query AS
(
/* Base Query: Retrieve from different tables column*/
	SELECT
	f.order_number,
	f.customer_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
)

, products_aggregation AS
(
/* Aggregating base query table */
SELECT
product_key,
product_name,
category,
subcategory,
cost,
COUNT(DISTINCT order_number) AS total_order,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT customer_key) AS total_customers,
MAX(order_date) AS last_order_date,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

SELECT
/* Final Query Output*/
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	lifespan,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_in_month,
	last_order_date,
	total_order,
	total_sales,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performers'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performers'
	END product_segment,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average order revenue (AOR)
	CASE
		WHEN total_order = 0 THEN 0
		ELSE total_sales / total_order
	END average_order_rev,
	-- Average monthly revenue (AMR)
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END average_monthly_rev
FROM products_aggregation
