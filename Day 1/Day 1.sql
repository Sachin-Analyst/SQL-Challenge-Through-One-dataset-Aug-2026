-- Pull all sales for Atliq Exclusive in India.

#Error Query 
SELECT 
    fs.date, 
    dp.product,
    dc.customer,
    dc.market, 
    fs.sold_quantity
FROM gdb0041.fact_sales_monthly fs
JOIN gdb0041.dim_customer dc
    ON dc.customer_code = fs.customer_code
JOIN gdb0041.dim_product dp
    ON dp.product_code = fs.product_code
WHERE dc.customer = 'Atliq Exclusive';



-- Fix Query 
SELECT 
    fs.date, 
    dp.product,
    dc.customer,
    dc.market, 
    fs.sold_quantity
FROM gdb0041.fact_sales_monthly fs
JOIN gdb0041.dim_customer dc
    ON dc.customer_code = fs.customer_code
JOIN gdb0041.dim_product dp
    ON dp.product_code = fs.product_code
WHERE dc.market = 'India' AND dc.customer = 'Atliq Exclusive'