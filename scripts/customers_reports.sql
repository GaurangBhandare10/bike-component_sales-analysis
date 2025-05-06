/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE or REPLACE VIEW gold.report_customers AS

WITH base_query AS(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF(year, c.birthdate, GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE 
	 WHEN age < 20 THEN 'Under 20'
	 WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 39 THEN '30-39'
	 WHEN age between 40 and 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
CASE 
    WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
    WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
    ELSE 'New'
END AS customer_segment,
last_order_date,
DATEDIFF(month, last_order_date, GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products
lifespan,
-- Compuate average order value (AVO)
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value,
-- Compuate average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
     ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation


-- SAMPLE OUTPUT
-- | Customer Key | Customer Number | Customer Name     | Age | Age Group      | Customer Segment | Last Order Date | Recency | Total Orders | Total Sales | Total Quantity | Total Products | Lifespan | Avg Order Value | Avg Monthly Spend |
-- |--------------|------------------|--------------------|-----|----------------|------------------|------------------|---------|---------------|-------------|----------------|----------------|----------|------------------|--------------------|
-- | 1            | AW00011000       | Jon Yang           | 54  | 50 and above   | VIP              | 2013-05-03       | 144     | 3             | 8249        | 8              | 8              | 2749     | 294              |
-- | 2            | AW00011001       | Eugene Huang       | 49  | 40-49          | VIP              | 2013-12-10       | 137     | 3             | 6384        | 11             | 10             | 2128     | 182              |
-- | 3            | AW00011002       | Ruben Torres       | 54  | 50 and above   | VIP              | 2013-02-23       | 147     | 3             | 8114        | 4              | 4              | 2704     | 324              |
-- | 4            | AW00011003       | Christy Zhu        | 52  | 50 and above   | VIP              | 2013-05-10       | 144     | 3             | 8139        | 9              | 9              | 2713     | 280              |
-- | 5            | AW00011004       | Elizabeth Johnson  | 46  | 40-49          | VIP              | 2013-05-01       | 144     | 3             | 8196        | 6              | 6              | 2732     | 292              |
-- | 6            | AW00011005       | Julio Ruiz         | 49  | 40-49          | VIP              | 2013-05-02       | 144     | 3             | 8121        | 6              | 6              | 2707     | 280              |
-- | 7            | AW00011006       | Janet Alvarez      | 49  | 40-49          | VIP              | 2013-05-14       | 144     | 3             | 8119        | 5              | 5              | 2706     | 289              |
-- | 8            | AW00011007       | Marco Mehta        | 56  | 50 and above   | VIP              | 2013-03-19       | 146     | 3             | 8211        | 8              | 8              | 2737     | 315              |
-- | 9            | AW00011008       | Rob Verhoff        | 50  | 50 and above   | VIP              | 2013-03-02       | 146     | 3             | 8106        | 7              | 7              | 2702     | 311              |
-- | 10           | AW00011009       | Shannon Carlson    | 56  | 50 and above   | VIP              | 2013-05-09       | 144     | 3             | 8091        | 5              | 5              | 2697     | 288              |
