# Day 9 / 15 -- Two Deductions Tables, Two Different Grains

**Dataset:** AtliQ Hardware (`gdb0041`) | **Tool:** MySQL | **Date:** 04/08/2026

[View-Fix-query](./Day-9-Fix-query.sql)

---

## The Ask

![Challenge-question](./Day-9-Challenge.png)

Day 9 of 15, same dataset (AtliQ Hardware, `gdb0041`) as every other day in this series.

Finance is back: after the invoice there are more deductions -- `discounts_pct` and `other_deductions_pct`, both in `fact_post_invoice_deductions`. Subtract those and there's finally a true net sales figure.

Today's question: add post-invoice deductions correctly to get net sales, without inflating the numbers.

## The Trap

Yesterday's pre-invoice deductions joined cleanly on `customer_code` and `fiscal_year`. The obvious next move is to join post-invoice deductions the exact same way -- same two columns, same pattern that just worked.

The moment that join runs, the row count jumps and totals quietly shift. `fact_pre_invoice_deductions` really is keyed by customer and fiscal year, one row per customer per year. `fact_post_invoice_deductions` is keyed much finer -- customer_code, product_code, and date. Joining on only `customer_code` and `fiscal_year` means every sales row matches every post-invoice row for that customer's whole year instead of matching the one row that actually applies -- the join fans out, and every downstream total inflates along with it.

## The Fix

Match the join key to what the table is actually keyed by, not to whatever worked last time:

```sql
JOIN post_invoice_report poir
ON poir.customer_code = nisr.customer_code
AND poir.product_code = nisr.product_code
AND poir.date = nisr.date
```

Three columns, matching the post-invoice table's real primary key, brings each sales row back to exactly the one post-invoice deduction row it belongs to.

## Bonus Find: The Join Key Isn't One-Size-Fits-All

The two deductions tables in this dataset have genuinely different grains, and that's the whole trap: `customer_code + fiscal_year` is the correct key for `fact_pre_invoice_deductions`, but it silently produces the wrong calculation the moment it's reused for `fact_post_invoice_deductions`. Each deductions table needs its join key checked against its own actual primary key -- assuming yesterday's key still applies today is exactly what fans the row count out.

## Why It Works

Same idea as a shipment's billing process, four stages deep: pickup logs every shipment as booked, a rate card attaches a price per shipment, a loyalty discount applies once a year per customer, and a route discount applies per shipment with its own tracking ID. The route discount can't be matched using only the customer's yearly loyalty record -- it needs the shipment's own tracking ID, because that's the actual level the discount was recorded at. Same reasoning applies to `fact_post_invoice_deductions`: it was recorded at the product-and-date level, so that's the level it has to be joined at.

## Fix Query

```sql
WITH sales_report AS (
SELECT 	fsm.date, fsm.fiscal_year, fsm.product_code,
fsm.customer_code, fsm.sold_quantity
FROM fact_sales_monthly fsm ),

gross_sales_report AS (
SELECT 
  sr.date, sr.customer_code, sr.fiscal_year, sr.product_code,
sr.sold_quantity * fgp.gross_price gross_sales_amount
FROM sales_report sr 
JOIN fact_gross_price fgp
ON sr.product_code = fgp.product_code 
AND sr.fiscal_year = fgp.fiscal_year ),

pre_invoice_report AS (                             
    SELECT 
        preivd.customer_code, preivd.fiscal_year,
        preivd.pre_invoice_discount_pct
    FROM fact_pre_invoice_deductions preivd),

net_invoice_sales_report AS (
SELECT gsr.date, gsr.fiscal_year, gsr.product_code, gsr.customer_code,
gsr.gross_sales_amount, 
gsr.gross_sales_amount * (1 - pir.pre_invoice_discount_pct) AS net_invoice_sales_amount
 FROM gross_sales_report gsr
 JOIN pre_invoice_report pir
 ON pir.customer_code = gsr.customer_code
 AND pir.fiscal_year = gsr.fiscal_year),
 
 post_invoice_report AS (
 SELECT fpid.date, fpid.customer_code, fpid.product_code,
 fpid.discounts_pct, fpid.other_deductions_pct
 FROM fact_post_invoice_deductions fpid)

SELECT nisr.fiscal_year, nisr.customer_code,
ROUND(nisr.gross_sales_amount,2) gross_sales_amount,
ROUND(nisr.net_invoice_sales_amount,2) net_invoice_amount,
ROUND(nisr.net_invoice_sales_amount 
        * (1 - (poir.discounts_pct + poir.other_deductions_pct)), 2) AS net_sales_amount
FROM net_invoice_sales_report nisr
JOIN post_invoice_report poir
ON poir.customer_code = nisr.customer_code
AND poir.product_code = nisr.product_code
AND poir.date = nisr.date;
```

Full file: [View-Fix-query](./Day-9-Fix-query.sql)

## Result

Unlike earlier days, this query doesn't aggregate up to one row per customer per year -- it keeps each individual sale at its own product-and-date grain, matched to its correct deduction row. That naturally means a lot more rows: 1,424,923 in total. A preview:

| fiscal_year | customer_code | gross_sales_amount | net_invoice_amount | net_sales_amount |
|---|---|---|---|---|
| 2022 | 80007195 | 958974.58 | 678090.92 | 377832.26 |
| 2022 | 80007195 | 861575.37 | 609219.94 | 402877.15 |
| 2022 | 80007196 | 856008.81 | 614443.12 | 391215.94 |
| 2022 | 80007196 | 811769.24 | 582687.96 | 360217.70 |
| 2022 | 80007195 | 797312.26 | 563779.50 | 367189.59 |
| 2022 | 80007196 | 754426.79 | 541527.55 | 309320.54 |
| 2022 | 80007195 | 714754.70 | 505403.04 | 311227.20 |
| 2022 | 80007196 | 699228.71 | 501906.37 | 313892.24 |

Full exported result: [Results](./Results)

## Takeaway

-- A join key that worked correctly for one table isn't guaranteed to work for another table, even a related one in the same dataset. Check the actual primary key of whatever you're joining to before reusing a key that worked last time.
-- Row counts jumping after a join is a strong signal of a grain mismatch -- the fix isn't to filter the extra rows away, it's to find the join key that matches the table's real grain in the first place.

---

**Original LinkedIn post:** [Linkedin-post-URL](https://www.linkedin.com/posts/vishnu-ram-sachin-d-_day-9-learnings-by-sachin-activity-7490622183212412928-0dfE?utm_source=share&utm_medium=member_desktop&rcm=ACoAAD-YjK4B1ekkuKaP0cSvVwYi6kAAiCTAQhY)
**Dataset reference (Codebasics course):** https://codebasics.io/courses/bootcamp/1/sql-beginner-to-advanced-for-data-professionals/lecture/1070
