

WITH gross_sales_report AS (SELECT 
	fsm.fiscal_year,
    ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2) gross_sales_mln,
    dc.market,
    RANK() OVER (ORDER BY SUM(fsm.sold_quantity * fgp.gross_price) DESC) AS rnk
FROM gdb0041.fact_sales_monthly fsm
JOIN dim_customer dc
	ON dc.customer_code = fsm.customer_code
JOIN fact_gross_price fgp
	ON fgp.product_code = fsm.product_code 
    AND fgp.fiscal_year = fsm.fiscal_year
WHERE fsm.fiscal_year = 2021 
GROUP BY dc.market)

SELECT 
gsr.fiscal_year, gsr.market, gsr.gross_sales_mln, gsr.rnk
FROM gross_sales_report gsr
WHERE rnk <=5
ORDER BY rnk;



WITH gross_sales_report AS (SELECT 
	fsm.fiscal_year,
   ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2) gross_sales_mln,
    dc.market
FROM gdb0041.fact_sales_monthly fsm
JOIN dim_customer dc
	ON dc.customer_code = fsm.customer_code
JOIN fact_gross_price fgp
	ON fgp.product_code = fsm.product_code 
    AND fgp.fiscal_year = fsm.fiscal_year
WHERE fsm.fiscal_year = 2021 
GROUP BY dc.market)

SELECT gsr.fiscal_year, gsr.market,
gsr.gross_sales_mln
FROM gross_sales_report gsr
ORDER BY gsr.gross_sales_mln DESC
LIMIT 5;











































