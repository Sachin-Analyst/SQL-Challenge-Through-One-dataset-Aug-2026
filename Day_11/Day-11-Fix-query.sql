WITH gross_sales_report AS (
SELECT 
	dc.customer_code , dc.customer , 
    dc.channel, dc.market, dd.fiscal_year,	
	fsm.sold_quantity * fgp.gross_price	AS gross_sales 
    FROM fact_sales_monthly fsm 
    JOIN dim_customer dc
		ON dc.customer_code = fsm.customer_code
	JOIN fact_gross_price fgp
		ON fgp.product_code = fsm.product_code 
        AND fgp.fiscal_year = fsm.fiscal_year
	JOIN dim_date dd
		ON dd.calender_date = fsm.date 
	WHERE dd.fiscal_year IN (2020,2021)),
    
    
    market_yearly_report AS (
    SELECT gsr.market ,
    SUM(CASE WHEN fiscal_year = 2020 THEN gross_sales ELSE 0 END) AS fy_2020_sales,
    SUM(CASE WHEN fiscal_year = 2021 THEN gross_sales ELSE 0 END) AS fy_2021_sales
    FROM gross_sales_report gsr
    GROUP BY gsr.market
    )

    SELECT 
    myr.market,
    ROUND(myr.fy_2020_sales/1000000,2) AS fy_2020_mln ,
    ROUND(myr.fy_2021_sales/1000000,2) AS fy_2021_mln,
    ROUND((myr.fy_2021_sales - myr.fy_2020_sales) / NULLIF(myr.fy_2020_sales, 0) * 100,
    2) AS grow_pct
    FROM market_yearly_report myr
    ORDER BY myr.market;
    
    
