WITH gross_sales_report AS (
	SELECT dc.customer, dc.market , fsm.fiscal_year , fsm.product_code, 
		fsm.customer_code, fsm.date,
		fsm.sold_quantity * fgp.gross_price AS gross_sales_mln
	FROM fact_sales_monthly fsm 
		JOIN fact_gross_price fgp 
			ON fsm.product_code = fgp.product_code
			AND fsm.fiscal_year =  fgp.fiscal_year
		JOIN dim_customer dc
			ON fsm.customer_code = dc.customer_code
	WHERE fsm.fiscal_year = 2021),

net_invoice_sales_report AS (
	SELECT gsr.customer , gsr.fiscal_year , 
		gsr.market, gsr.customer_code, gsr.product_code, gsr.date, 
		gsr.gross_sales_mln * (1 - fpid.pre_invoice_discount_pct) AS net_invoice_sales
	FROM gross_sales_report gsr
			JOIN fact_pre_invoice_deductions fpid 
				ON gsr.customer_code = fpid.customer_code 
				AND gsr.fiscal_year =  fpid.fiscal_year ),
    
net_sales_report AS (
	SELECT nisr.customer, nisr.fiscal_year, nisr.market, 
		nisr.customer_code, nisr.date,
		nisr.net_invoice_sales * (1- (fpoid.discounts_pct + fpoid.other_deductions_pct))
		AS net_sales
	FROM net_invoice_sales_report nisr
		JOIN fact_post_invoice_deductions fpoid
			ON nisr.customer_code = fpoid.customer_code
            AND nisr.product_code = fpoid.product_code
			AND nisr.date = fpoid.date
),
customer_sales_report AS (
	SELECT nsr.customer_code, nsr.customer, nsr.market, 
		ROUND(SUM(nsr.net_sales)/1000000,2) AS net_sales_mln
	FROM net_sales_report nsr 
	GROUP BY nsr.customer_code, nsr.customer , nsr.market),
    
ranked_report AS (
	SELECT csr.customer, csr.market, csr.net_sales_mln ,
		RANK () OVER (ORDER BY csr.net_sales_mln DESC ) AS rank_order, 
		ROUND(csr.net_sales_mln*100/ SUM(csr.net_sales_mln) OVER (),2) 
		AS pct_of_total
    FROM customer_sales_report csr
)
SELECT 	
	rr.customer, rr.market , rr.net_sales_mln  , rr.pct_of_total ,  rr.rank_order
FROM ranked_report rr
WHERE rank_order <=10
ORDER BY rank_order ASC;	

