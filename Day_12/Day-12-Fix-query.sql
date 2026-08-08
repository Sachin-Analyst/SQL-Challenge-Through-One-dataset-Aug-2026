WITH gross_sales_report AS (
SELECT fsm.date, fsm.product_code , fsm.fiscal_year,
MONTHNAME(fsm.date) AS fiscal_month_name,
fsm.customer_code, 
ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2) AS gross_sales
FROM fact_sales_monthly fsm 
	JOIN fact_gross_price fgp 
    ON fgp.product_code = fsm.product_code
    AND fgp.fiscal_year = fsm.fiscal_year
    GROUP BY fsm.fiscal_year , fsm.date
    ORDER BY fsm.fiscal_year,fsm.date	)

SELECT 	
gsr.fiscal_year , gsr.fiscal_month_name , gsr.gross_sales, 
SUM(gsr.gross_sales) OVER (PARTITION BY gsr.fiscal_year
ORDER BY gsr.date ) AS running_total
FROM gross_sales_report gsr
ORDER BY gsr.fiscal_year, gsr.date;