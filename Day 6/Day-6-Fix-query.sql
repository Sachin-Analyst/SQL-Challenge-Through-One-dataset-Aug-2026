
WITH gross_sales_report AS (SELECT 
	fsm.fiscal_year,
    ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2) gross_sales_mln,
    dc.market,
    
    RANK() OVER (ORDER BY SUM(fsm.sold_quantity * fgp.gross_price) DESC) rnk
FROM gdb0041.fact_sales_monthly fsm
JOIN dim_customer dc
	ON dc.customer_code = fsm.customer_code
JOIN fact_gross_price fgp
	ON fgp.product_code = fsm.product_code 
    AND fgp.fiscal_year = fsm.fiscal_year
WHERE fsm.fiscal_year = 2021 
GROUP BY dc.market),

grand_total_report AS (
SELECT gsr.market , gsr.gross_sales_mln, 
ROUND(gsr.gross_sales_mln*100 / SUM(gsr.gross_sales_mln) OVER(),2) pct_of_total
FROM gross_sales_report gsr

)

SELECT gtr.market,
gtr.gross_sales_mln,
gtr.pct_of_total
FROM grand_total_report gtr;