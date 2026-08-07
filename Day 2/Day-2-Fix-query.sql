

--- Error Query it returns FY2022 date 

SELECT * FROM gdb0041.fact_sales_monthly
WHERE YEAR(date)=2021;



--- FIX QUERY TO GET FY2021 SALES

SELECT *
FROM gdb0041.fact_sales_monthly
WHERE YEAR(DATE_ADD(date, INTERVAL 4 MONTH)) = 2021;



EXPLAIN ANALYZE
SELECT * FROM gdb0041.fact_sales_monthly
WHERE YEAR(DATE_ADD(date, INTERVAL 4 MONTH)) = 2021;


EXPLAIN ANALYZE
SELECT * FROM gdb0041.fact_sales_monthly
WHERE CASE WHEN MONTH(date) >= 9 THEN YEAR(date) + 1 ELSE YEAR(date) END = 2021;