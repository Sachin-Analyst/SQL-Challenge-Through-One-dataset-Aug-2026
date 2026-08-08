WITH gross_sales_report AS (
	SELECT 	 
		dc.customer_code,
		dc.customer,
		dc.market,
		preivd.pre_invoice_discount_pct,
		ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2) gross_sales_mln
    FROM fact_sales_monthly fsm 
    JOIN dim_customer dc
		ON dc.customer_code = fsm.customer_code
    JOIN fact_gross_price fgp 
		ON fgp.product_code = fsm.product_code
		AND fgp.fiscal_year = fsm.fiscal_year
    JOIN fact_pre_invoice_deductions preivd
		ON preivd.customer_code = fsm.customer_code
		AND preivd.fiscal_year = fsm.fiscal_year 
    GROUP BY dc.customer_code, fsm.fiscal_year
    
    )
SELECT 
	 gsr.customer_code, gsr.gross_sales_mln, 
    ROUND(gsr.gross_sales_mln * (1 - gsr.pre_invoice_discount_pct),2) net_invoice_sales
    FROM gross_sales_report gsr 
    ORDER BY gsr.gross_sales_mln DESC;
    
    
    
    
