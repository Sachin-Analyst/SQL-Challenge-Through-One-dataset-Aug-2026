SELECT 
	fsm.fiscal_year,
    MONTHNAME(fsm.date) sales_month_name,
    CONCAT(ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2),' Mln') gross_sales_mln
FROM gdb0041.fact_sales_monthly fsm
JOIN dim_customer dc
	ON dc.customer_code = fsm.customer_code
JOIN dim_product dp
	ON dp.product_code = fsm.product_code
JOIN fact_gross_price fgp
	ON fgp.product_code = fsm.product_code 
    AND fgp.fiscal_year = fsm.fiscal_year
WHERE 
	dc.customer = 'Atliq E store' 
    AND fsm.fiscal_year = 2021 
    AND dc.market = 'India'
GROUP BY YEAR(fsm.date), MONTH(fsm.date), MONTHNAME(fsm.date)
ORDER BY YEAR(fsm.date), MONTH(fsm.date);









