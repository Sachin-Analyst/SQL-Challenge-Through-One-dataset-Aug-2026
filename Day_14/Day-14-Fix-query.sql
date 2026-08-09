
SELECT fsm.fiscal_year , 
	COUNT(DISTINCT(fsm.customer_code)) AS fy_unique_customers
	FROM fact_sales_monthly fsm
		WHERE fsm.fiscal_year IN (2020,2021)
		GROUP BY fsm.fiscal_year;

SELECT 
DISTINCT fy21.customer_code 
	FROM fact_sales_monthly fy21
	WHERE fy21.fiscal_year = 2021 
	AND NOT EXISTS (
	SELECT 1 
		FROM fact_sales_monthly fy20
		WHERE fy21.customer_code = fy20.customer_code
		AND fy20.fiscal_year = 2020
		)


