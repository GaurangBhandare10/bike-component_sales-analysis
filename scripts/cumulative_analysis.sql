/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

--  total sales per month and the running total of sales every month of a particular year
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (partition by DATETRUNC(year, order_date) ORDER BY order_date) AS running_total_sales
FROM
(
    SELECT 
        DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
)t 

-- SAMPLE OUTPUT
-- | order_date | total_sales | running_total_sales |
-- |------------|-------------|----------------------|
-- | 01-12-2010 | 43419       | 43419                |
-- | 01-01-2011 | 469795      | 469795               |
-- | 01-02-2011 | 466307      | 936102               |
-- | 01-03-2011 | 485165      | 1421267              |
-- | 01-04-2011 | 502042      | 1923309              |
-- | 01-05-2011 | 561647      | 2484956              |
-- | 01-06-2011 | 737793      | 3222749              |
-- | 01-07-2011 | 596710      | 3819459              |
-- | 01-08-2011 | 614516      | 4433975              |
-- | 01-09-2011 | 603047      | 5037022              |
-- | 01-10-2011 | 708164      | 5745186              |
-- | 01-11-2011 | 660507      | 6405693              |

  ------------------------------------------------------------------------------------------------------------------------------------------------------

--  total sales each year , running total of sales and average sales each year
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t


-- SAMPLE OUTPUT

-- | order_date | total_sales | running_total_sales | moving_average_price |
-- |------------|-------------|----------------------|-----------------------|
-- | 2010-01-01 | 43419       | 43419                | 3101                  |
-- | 2011-01-01 | 7075088     | 7118507              | 3146                  |
-- | 2012-01-01 | 5842231     | 12960738             | 2670                  |
-- | 2013-01-01 | 16344878    | 29305616             | 2080                  |
-- | 2014-01-01 | 45642       | 29351258             | 1668                  |
