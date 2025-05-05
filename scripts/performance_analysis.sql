/*
===============================================================================
Performance Analysis (Year-over-Year)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

 Analyzed the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */


WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)

select order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
  CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
	  CASE 
        WHEN current_sales -LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)  >0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)  < 0 THEN 'Decrease'
        ELSE 'Avg'
    END AS py_change
from yearly_product_sales


--SAMPLE OUTPUT

-- | Year | Product               | Sales | Avg Sales | Prev Year Sales | Performance   |   Trend   |
-- |------|------------------------|-------|-----------|------------------|-------------|-----------|
-- | 2012 | All-Purpose Bike Stand | 159   | 13197     | NULL             | Below Avg   | Avg       |
-- | 2013 | All-Purpose Bike Stand | 37683 | 13197     | 159              | Above Avg   | Increase  |
-- | 2014 | All-Purpose Bike Stand | 1749  | 13197     | 37683            | Below Avg   | Decrease  |
-- | 2012 | AWC Logo Cap           | 72    | 6570      | NULL             | Below Avg   | Avg       |
-- | 2013 | AWC Logo Cap           | 18891 | 6570      | 72               | Above Avg   | Increase  |
-- | 2014 | AWC Logo Cap           | 747   | 6570      | 18891            | Below Avg   | Decrease  |
-- | 2013 | Bike Wash - Dissolver  | 6960  | 3636      | NULL             | Above Avg   | Avg       |
-- | 2014 | Bike Wash - Dissolver  | 312   | 3636      | 6960             | Below Avg   | Decrease  |
-- | 2013 | Classic Vest- L        | 11968 | 6240      | NULL             | Above Avg   | Avg       |
-- | 2014 | Classic Vest- L        | 512   | 6240      | 11968            | Below Avg   | Decrease  |

