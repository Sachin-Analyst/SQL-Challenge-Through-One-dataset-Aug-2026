WITH sales_report AS (
SELECT 	fsm.date, fsm.fiscal_year,fsm.product_code,
fsm.customer_code, fsm.sold_quantity
FROM fact_sales_monthly fsm ),

gross_sales_report AS (
SELECT 
  sr.customer_code, sr.fiscal_year,
ROUND(SUM(sr.sold_quantity * fgp.gross_price)/1000000,2) gross_sales_mln
FROM sales_report sr 
JOIN fact_gross_price fgp
ON sr.product_code = fgp.product_code 
AND sr.fiscal_year = fgp.fiscal_year 
GROUP BY sr.customer_code, sr.fiscal_year) ,

pre_invoice_report AS (                             
    SELECT 
        preivd.customer_code, 
        preivd.fiscal_year,
        preivd.pre_invoice_discount_pct
    FROM fact_pre_invoice_deductions preivd
)

SELECT                                              
    gsr.customer_code, 
    gsr.gross_sales_mln, 
    ROUND(gsr.gross_sales_mln * (1 - pir.pre_invoice_discount_pct),2) net_invoice_sales
FROM gross_sales_report gsr 
JOIN pre_invoice_report pir
    ON pir.customer_code = gsr.customer_code
    AND pir.fiscal_year = gsr.fiscal_year
ORDER BY gsr.gross_sales_mln DESC;
