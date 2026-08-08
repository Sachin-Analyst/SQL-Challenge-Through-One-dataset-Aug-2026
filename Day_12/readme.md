# Day 12 / 15 -- A Running Total That Resets on Its Own Calendar

**Dataset:** AtliQ Hardware (`gdb0041`) | **Tool:** MySQL | **Date:** 07/08/2026

[View fix-query.sql](./fix-query.sql)

---

## The Ask

![Codebasics ask on Discord](./assets/challenge/discord-ask.png)

Day 12 of 15, same dataset (AtliQ Hardware, `gdb0041`) as every other day in this series.

Leadership wants to watch a fiscal year build up, month by month -- each month's sales plus everything earlier in that same year, a running total. And it has to reset the moment a new fiscal year starts.

Today's question: add a `running_total` column that accumulates within a fiscal year and resets at each new one.

## The Trap

Series 1 already covered a running total using `ORDER BY` inside `OVER()`, so the instinct is to reuse that exact pattern here with `ORDER BY fiscal_month_name`.

The problem is `fiscal_month_name` is text, and text sorts alphabetically, not chronologically. March gets evaluated after August because "M" comes after "A" alphabetically, even though March is months earlier in the actual calendar. The running total ends up accumulating in the wrong sequence, breaking the moment it crosses from one real month into another, well before the fiscal year itself is even done.

## The Fix

Partition by fiscal year first, then order by the actual date, not the month's name:

```sql
SUM(gsr.gross_sales) OVER (PARTITION BY gsr.fiscal_year
ORDER BY gsr.date) AS running_total
```

`PARTITION BY fiscal_year` is what makes the total reset -- each fiscal year gets its own independent running sum. `ORDER BY date` is what keeps the accumulation in true chronological order, September through August, instead of alphabetical order.

## Why It Works

Same idea as a car's odometer, four stages deep: every trip logged with no reset at all just mixes all the mileage together into one meaningless number. Reset it every year instead, rolling back every September, and that's `PARTITION BY fiscal_year` -- each year starts counting from zero again. Within that reset, the trips still need to be counted in the order they actually happened, September through August, not alphabetically, which is what `ORDER BY date` guarantees. Only then does the running distance make sense, each month's reading added onto the last one in the correct sequence. Same reasoning applies here: partition resets the count, and ordering by the real date keeps what accumulates inside that reset honest.

## Fix Query

```sql
WITH gross_sales_report AS (
SELECT fsm.date, fsm.product_code , fsm.fiscal_year,
MONTHNAME(fsm.date) AS fiscal_month_name,
fsm.customer_code, 
ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2) AS gross_sales
FROM fact_sales_monthly fsm 
	JOIN fact_gross_price fgp 
    ON fgp.product_code = fsm.product_code
    AND fgp.fiscal_year = fsm.fiscal_year
    GROUP BY fsm.fiscal_year , fsm.date
    ORDER BY fsm.fiscal_year,fsm.date	)

SELECT 	
gsr.fiscal_year , gsr.fiscal_month_name , gsr.gross_sales, 
SUM(gsr.gross_sales) OVER (PARTITION BY gsr.fiscal_year
ORDER BY gsr.date ) AS running_total
FROM gross_sales_report gsr
ORDER BY gsr.fiscal_year, gsr.date;
```

Full file: [fix-query.sql](./fix-query.sql)

## Result

Each fiscal year builds up cleanly in true month order and resets the moment the next one starts. A preview around that exact reset point:

| fiscal_year | fiscal_month_name | gross_sales | running_total |
|---|---|---|---|
| 2018 | September | 4.19 | 4.19 |
| 2018 | October | 5.30 | 9.49 |
| 2018 | November | 7.42 | 16.91 |
| 2018 | December | 7.54 | 24.45 |
| 2018 | January | 4.19 | 28.64 |
| 2018 | February | 4.04 | 32.68 |
| 2018 | March | 4.46 | 37.14 |
| 2018 | April | 4.25 | 41.39 |
| 2018 | May | 4.24 | 45.63 |
| 2018 | June | 4.13 | 49.76 |
| 2018 | July | 4.24 | 54.00 |
| 2018 | August | 4.32 | 58.32 |
| 2019 | September | 15.14 | 15.14 |

Fiscal year 2018 climbs steadily from 4.19 million all the way to 58.32 million by August, its last month. The moment September 2019 begins, `running_total` drops back down and starts over at 15.14 -- exactly the reset the ask called for.

Full exported result: [Results](./Results)

## Takeaway

-- Ordering by a text version of a date field (like a month name) sorts alphabetically, not chronologically. Always order by the real date column when sequence actually matters.
-- `PARTITION BY` is what resets an accumulating value; `ORDER BY` inside the same window is what decides the order it accumulates in. They solve two different problems and both need to be right for a running total to behave.

---

**Original LinkedIn post:** [add link here]
**Dataset reference (Codebasics course):** https://codebasics.io/courses/bootcamp/1/sql-beginner-to-advanced-for-data-professionals/lecture/1070
