WITH ranked_products_report AS (
SELECT 
	dp.product_code , dp.product , dp.division, 
	SUM(fsm.sold_quantity) total_sold_quantity,
	RANK() OVER (PARTITION BY division ORDER BY SUM(fsm.sold_quantity) DESC ) AS product_rank
FROM fact_sales_monthly fsm 
	JOIN dim_product dp
		ON fsm.product_code = dp.product_code
GROUP BY dp.division , dp.product_code )
    
SELECT 
rpp.product_code , rpp.product , 
rpp.division , rpp.total_sold_quantity, rpp.product_rank
 FROM ranked_products_report rpp
    WHERE product_rank <=3
    ORDER BY rpp.division , rpp.product_rank;