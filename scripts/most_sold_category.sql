/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
 -- To evaluate differences between categories.
 -- To find the most impactful cateogry to the business
===============================================================================
*/

WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

-- SAMPLE OUTPUT
-- | Total Sales | Category    | Overall Sales | Percentage of Total |
-- |-------------|-------------|----------------|----------------------|
-- | 28316272    | Bikes       | 29356250       | 96.46%               |
-- | 700262      | Accessories | 29356250       | 2.39%                |
-- | 339716      | Clothing    | 29356250       | 1.16%                |
