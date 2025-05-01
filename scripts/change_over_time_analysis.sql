/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATETRUNC(), MONTH()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/
-- 📆 Yearly Sales Data (2010–2014)
SELECT
    YEAR(order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- SAMPLE OUTPUT

-- | order_date | total_sales | total_customers | total_quantity |
-- |------------|-------------|------------------|----------------|
-- | 2010       | 43419       | 14               | 14             |
-- | 2011       | 7075088     | 2216             | 2216           |
-- | 2012       | 5842231     | 3255             | 3397           |
-- | 2013       | 16344878    | 17427            | 52807          |
-- | 2014       | 45642       | 834              | 1970           |

--------------------------------------------------------------------------------------------------------------------------------------------
-- 🗓️ Monthly Sales Data (Months 1–12)

SELECT
    MONTH(order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

-- SAMPLE OUTPUT

-- | order_date | total_sales | total_customers | total_quantity |
-- |------------|-------------|------------------|----------------|
-- | 1          | 1868558     | 1818             | 4043           |
-- | 2          | 1744517     | 1765             | 3858           |
-- | 3          | 1908375     | 1982             | 4449           |
-- | 4          | 1948226     | 1916             | 4355           |
-- | 5          | 2204969     | 2074             | 4781           |
-- | 6          | 2935883     | 2430             | 5573           |
-- | 7          | 2412838     | 2154             | 5107           |
-- | 8          | 2684313     | 2312             | 5335           |
-- | 9          | 2536520     | 2210             | 5070           |
-- | 10         | 2916550     | 2533             | 5838           |
-- | 11         | 2979113     | 2500             | 5756           |
-- | 12         | 3211396     | 2656             | 6239           |

-------------------------------------------------------------------------------------------------------------------------------------------

-- 📆 total sales in each month of a single  year
SELECT
    DATETRUNC(month, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- SAMPLE OUTPUT
-- | order_date | total_sales | total_customers | total_quantity |
-- |------------|-------------|------------------|----------------|
-- | 01-06-2012 | 555142      | 318              | 318            |
-- | 01-07-2012 | 444533      | 246              | 246            |
-- | 01-08-2012 | 523887      | 294              | 294            |
-- | 01-09-2012 | 486149      | 269              | 269            |
-- | 01-10-2012 | 535125      | 313              | 313            |
-- | 01-11-2012 | 537918      | 324              | 324            |
-- | 01-12-2012 | 624454      | 354              | 483            |
-- | 01-01-2013 | 857758      | 627              | 1677           |
-- | 01-02-2013 | 771218      | 1373             | 3454           |


