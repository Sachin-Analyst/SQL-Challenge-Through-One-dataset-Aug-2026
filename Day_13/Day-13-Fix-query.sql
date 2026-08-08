WITH forecast_actual_compare_report AS (
    SELECT 
		fsm.date, 
        MONTHNAME(fsm.date) AS month_name , fsm.customer_code, fsm.product_code,
        fsm.fiscal_year,
		COALESCE(ffm.forecast_quantity, 0) AS forecast_quantity,
		fsm.sold_quantity
    FROM fact_sales_monthly AS fsm
		LEFT JOIN fact_forecast_monthly AS ffm
			ON fsm.date = ffm.date
			AND fsm.customer_code = ffm.customer_code
			AND fsm.product_code = ffm.product_code
            
    UNION ALL
    
    SELECT
        ffm.date, 
        MONTHNAME(ffm.date) AS month_name, ffm.customer_code, 
        ffm.fiscal_year,
        ffm.product_code, ffm.forecast_quantity, 0 AS sold_quantity
    FROM fact_forecast_monthly AS ffm
		LEFT JOIN fact_sales_monthly AS fsm
			ON ffm.date = fsm.date
			AND ffm.customer_code = fsm.customer_code
			AND ffm.product_code = fsm.product_code
	WHERE fsm.product_code IS NULL
)
SELECT 
facr.month_name, facr.fiscal_year,
facr.customer_code, facr.product_code, 
facr.forecast_quantity, facr.sold_quantity,
(forecast_quantity - sold_quantity) AS forecast_error
FROM forecast_actual_compare_report facr ;