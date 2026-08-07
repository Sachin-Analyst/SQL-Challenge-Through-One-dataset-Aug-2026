
SELECT 
	fs.product_code,
    fs.fiscal_year,
    ROUND(SUM(fs.sold_quantity * gp.gross_price)/1000000,2) AS gross_sales_mln	
    FROM gdb0041.fact_sales_monthly fs
		JOIN gdb0041.fact_gross_price gp
		ON fs.product_code=gp.product_code
        AND fs.fiscal_year=gp.fiscal_year
			GROUP BY fs.fiscal_year,fs.product_code;
            

        
        