/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
    SELECT
	    f.order_number,
        f.order_date,
		f.customer_key,
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
    WHERE order_date IS NOT NULL  -- only consider valid sales dates
),

product_aggregations AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query

GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)

/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM product_aggregations


--  SAMPLE OUTPUT 

-- | Product Key | Product Name            | Category | Subcategory     | Cost | Last Sale Date | Recency (Months) | Product Segment | Lifespan | Total Orders | Total Sales | Total Quantity | Total Customers | Avg Selling Price | Avg Order Revenue | Avg Monthly Revenue |
-- |-------------|--------------------------|----------|------------------|------|----------------|------------------|------------------|----------|---------------|-------------|----------------|------------------|--------------------|--------------------|----------------------|
-- | 3           | Mountain-100 Black- 38   | Bikes    | Mountain Bikes   | 1898 | 2011-12-27     | 161              | High-Performer   | 11       | 49            | 165375      | 49             | 49               | 3375               | 3375               | 15034                |
-- | 4           | Mountain-100 Black- 42   | Bikes    | Mountain Bikes   | 1898 | 2011-12-27     | 161              | High-Performer   | 11       | 45            | 151875      | 45             | 45               | 3375               | 3375               | 13806                |
-- | 5           | Mountain-100 Black- 44   | Bikes    | Mountain Bikes   | 1898 | 2011-12-21     | 161              | High-Performer   | 11       | 60            | 202500      | 60             | 60               | 3375               | 3375               | 18409                |
-- | 6           | Mountain-100 Black- 48   | Bikes    | Mountain Bikes   | 1898 | 2011-12-26     | 161              | High-Performer   | 12       | 57            | 192375      | 57             | 57               | 3375               | 3375               | 16031                |
-- | 7           | Mountain-100 Silver- 38  | Bikes    | Mountain Bikes   | 1912 | 2011-12-22     | 161              | High-Performer   | 12       | 58            | 197200      | 58             | 58               | 3400               | 3400               | 16433                |
-- | 8           | Mountain-100 Silver- 42  | Bikes    | Mountain Bikes   | 1912 | 2011-12-28     | 161              | High-Performer   | 11       | 42            | 142800      | 42             | 42               | 3400               | 3400               | 12981                |
-- | 9           | Mountain-100 Silver- 44  | Bikes    | Mountain Bikes   | 1912 | 2011-12-12     | 161              | High-Performer   | 12       | 49            | 166600      | 49             | 49               | 3400               | 3400               | 13883                |
-- | 10          | Mountain-100 Silver- 48  | Bikes    | Mountain Bikes   | 1912 | 2011-12-23     | 161              | High-Performer   | 11       | 36            | 122400      | 36             | 36               | 3400               | 3400               | 11127                |
-- | 16          | Road-150 Red- 44         | Bikes    | Road Bikes       | 2171 | 2011-12-28     | 161              | High-Performer   | 12       | 281           | 1005418     | 281            | 281              | 3578               | 3578               | 83784                |
