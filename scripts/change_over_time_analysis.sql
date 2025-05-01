/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATETRUNC()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

SELECT
    DATETRUNC(month, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);


order_date  total_sales   total_customers   total_quantity
2010-12-01	43419	           14	              14
2011-01-01	469795	           144	              144
2011-02-01	466307	           144	              144
2011-03-01	485165	           150	              150
2011-04-01	502042	           157	              157
2011-05-01	561647	           174	              174
2011-06-01	737793	           230	              230
2011-07-01	596710	           188	              188
2013-01-01	857758	           627	              1677
