# Day 11 / 15 -- Two Years, One Row: Pivoting FY2020 vs FY2021

**Dataset:** AtliQ Hardware (`gdb0041`) | **Tool:** MySQL | **Date:** 06/08/2026

[View fix-query.sql](./fix-query.sql)

---

## The Ask

![Codebasics ask on Discord](./assets/challenge/discord-ask.png)

Day 11 of 15, same dataset (AtliQ Hardware, `gdb0041`) as every other day in this series.

Leadership wants to know which markets grew from FY2020 to FY2021, and by how much. That means both fiscal years need to sit next to each other on one row per market, with a growth percentage next to them.

Today's question: build the YoY table -- market, FY2020, FY2021, growth %.

## The Trap

The instinct is to reach for `GROUP BY market, fiscal_year`. That gets one row per market per year, aggregated correctly, but it's still two separate rows per market, not two columns on one row.

Two rows can't be subtracted from each other in the same `SELECT`. There's no way to write `FY2021 - FY2020` when FY2020's number and FY2021's number are sitting on different rows entirely. The grouping is right, the shape is wrong.

## The Fix

Pivot the year into columns instead of rows, using conditional aggregation:

```sql
SUM(CASE WHEN fiscal_year = 2020 THEN gross_sales ELSE 0 END) AS fy_2020_sales,
SUM(CASE WHEN fiscal_year = 2021 THEN gross_sales ELSE 0 END) AS fy_2021_sales
```

Each `CASE WHEN` only counts a row toward its own year and zeroes out everything else, so the `SUM` collapses each market down to a single row with both years sitting in their own column, side by side. Now the growth math is a straight column-to-column subtraction:

```sql
ROUND((fy_2021_sales - fy_2020_sales) / NULLIF(fy_2020_sales, 0) * 100, 2) AS grow_pct
```

`NULLIF(fy_2020_sales, 0)` guards the division -- if a market had zero FY2020 sales, this turns the denominator into `NULL` instead of `0`, so the whole expression returns `NULL` instead of crashing on a divide-by-zero error.

## Why It Works

Same idea as reading a bank statement, four stages deep: every transaction listed out has all the months mixed together in one long list, which is the `GROUP BY month` version -- correct totals, wrong shape for comparison. Split by month instead, and January, February, March each get their own column, which is exactly what the `CASE WHEN` pivot does. That gives one row per account with every month sitting side by side, and only then can this month be compared against last month to see the actual change. Same reasoning applies here: the pivot is what turns two competing rows into one comparable row, and the growth percentage only becomes possible once both years live in the same row.

## Fix Query

```sql
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
```

Full file: [fix-query.sql](./fix-query.sql)

## Result

27 rows returned, one per market, each with both fiscal years sitting side by side and a growth percentage next to them. A preview:

| market | fy_2020_mln | fy_2021_mln | grow_pct |
|---|---|---|---|
| Australia | 23.81 | 59.15 | 148.42 |
| Austria | 0.31 | 8.25 | 2589.72 |
| Bangladesh | 5.66 | 19.05 | 236.78 |
| Brazil | 2.33 | 2.14 | -8.11 |
| Canada | 29.11 | 89.78 | 208.40 |
| Chile | 0.19 | 1.46 | 664.20 |
| China | 13.59 | 55.29 | 307.00 |
| Columbia | 0.03 | 0.37 | 1062.99 |
| France | 19.36 | 67.62 | 249.22 |
| Germany | 13.74 | 41.25 | 200.16 |
| India | 139.70 | 455.05 | 225.73 |
| Indonesia | 14.85 | 48.12 | 224.12 |
| Italy | 14.24 | 38.10 | 167.66 |
| Japan | 4.91 | 17.34 | 253.19 |

Brazil is the one market that shrank between the two years, everything else grew, some by a small amount and some many times over off a very low FY2020 base.

Full exported result: [Results](./Results)

## Takeaway

-- `GROUP BY` alone only decides how rows collapse, not what shape they collapse into. If the ask needs two time periods compared side by side, grouping by the time period keeps them on separate rows.
-- `CASE WHEN` inside an aggregate function is the pivot move -- it routes each row into the right column before the aggregate ever runs, turning "many rows across years" into "one row across columns."
-- Any time division shows up in a calculated column, check whether the denominator can be zero. `NULLIF` is the guard that turns a crash into a clean `NULL`.

---

**Original LinkedIn post:** [add link here]
**Dataset reference (Codebasics course):** https://codebasics.io/courses/bootcamp/1/sql-beginner-to-advanced-for-data-professionals/lecture/1070
