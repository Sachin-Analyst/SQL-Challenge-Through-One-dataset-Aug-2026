WITH sales_report AS (
SELECT 	fsm.date, fsm.fiscal_year,fsm.product_code,
fsm.customer_code, fsm.sold_quantity
FROM fact_sales_monthly fsm ),

gross_sales_report AS (
SELECT 
  sr.date , sr.customer_code, sr.fiscal_year, sr.product_code,
sr.sold_quantity * fgp.gross_price  gross_sales_amount
FROM sales_report sr 
JOIN fact_gross_price fgp
ON sr.product_code = fgp.product_code 
AND sr.fiscal_year = fgp.fiscal_year ) ,

pre_invoice_report AS (                             
    SELECT 
        preivd.customer_code, preivd.fiscal_year,
        preivd.pre_invoice_discount_pct
    FROM fact_pre_invoice_deductions preivd),

net_invoice_sales_report AS(
SELECT gsr.date ,gsr.fiscal_year, gsr.product_code , gsr.customer_code,
gsr.gross_sales_amount, 
gsr.gross_sales_amount * (1 - pir.pre_invoice_discount_pct) AS net_invoice_sales_amount
 FROM gross_sales_report gsr
 JOIN pre_invoice_report pir
 ON pir.customer_code = gsr.customer_code
 AND pir.fiscal_year = gsr.fiscal_year),
 
 post_invoice_report AS (
 SELECT fpid.date , fpid.customer_code , fpid.product_code,
 fpid.discounts_pct , fpid.other_deductions_pct
 FROM fact_post_invoice_deductions fpid	)


SELECT nisr.fiscal_year , nisr.customer_code,
ROUND(nisr.gross_sales_amount,2) gross_sales_amount,
ROUND(nisr.net_invoice_sales_amount,2) net_invoice_amount,
ROUND(nisr.net_invoice_sales_amount 
        * (1 - (poir.discounts_pct + poir.other_deductions_pct)), 2) AS net_sales_amount
FROM net_invoice_sales_report nisr
JOIN post_invoice_report poir
ON poir.customer_code = nisr.customer_code
AND poir.product_code = nisr.product_code
AND poir.date = nisr.date 

