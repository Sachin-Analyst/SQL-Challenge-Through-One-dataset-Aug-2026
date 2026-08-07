
# Day 2 / 15 -- Fiscal Year Filtering with DATE_ADD

**Dataset:** AtliQ Hardware (`gdb0041`) | **Tool:** MySQL | **Date:** 28/07/2026

[Day-2](./Day-2-Fix-Query.sql)

---

## The Ask

![Codebasics ask on Discord](./assets/challenge/discord-ask.png)

Day 2 of 15, same dataset (AtliQ Hardware, `gdb0041`) as every other day in this series.

The relevant table this time:

`fact_sales_monthly` -- `date`, `fiscal_year`, `product_code`, `customer_code`, `sold_quantity`

The manager's ask: **"Give me FY2021 sales."**

## The Trap

The obvious first move:

```sql
WHERE YEAR(date) = 2021
```

This runs clean, no errors, and looks correct. The problem is that AtliQ's fiscal year doesn't run January to December -- it starts in September. So `YEAR(date) = 2021` actually pulls two different fiscal years stitched together:

-- Jan-Aug 2021, which really is FY2021
-- Sep-Dec 2021, which is actually the start of FY2022

The trap query returned **619,763 rows** -- inflated by four months that don't belong.

## The Fix

Shift the date forward by 4 months before checking the year:

```sql
WHERE YEAR(DATE_ADD(date, INTERVAL 4 MONTH)) = 2021
```

September becomes January, and August becomes December. Once the shift is applied, every month that actually belongs to FY2021 (Sep 2020 through Aug 2021) lands on `YEAR() = 2021`, and nothing from FY2022 leaks in.

The fix query returned **608,108 rows** -- the real FY2021 scope.

## Bonus Find: fiscal_year Was Already There

`fact_sales_monthly` has a `fiscal_year` column sitting in the table the whole time:

`date | fiscal_year | product_code | customer_code | sold_quantity`

Worth checking the table structure before reaching for date math -- `customer_name` needed a join in Day 1, but here `fiscal_year` needed no computation at all, it was already there to filter on directly (`WHERE fiscal_year = 2021`). `YEAR(date)` was the one that needed the manual correction.

## Why It Works

Same idea as Indian income tax, which runs April to March, not January to December -- April 2020 through March 2021 is all one assessment year, FY2020-21, even though it spans two calendar years.

AtliQ's fiscal year works the same way, just starting in September instead of April. Fiscal year is a business calendar, not a calendar-year calendar -- and `DATE_ADD` is what re-aligns the two.

## Fix Query

```sql
SELECT
    date,
    fiscal_year,
    product_code,
    customer_code,
    sold_quantity
FROM gdb0041.fact_sales_monthly
WHERE YEAR(DATE_ADD(date, INTERVAL 4 MONTH)) = 2021;
```

Full file: [fix-query.sql](./fix-query.sql)

## Alternative Fix & Performance Check

There's a second way to write the same fix, without date arithmetic:

```sql
WHERE CASE WHEN MONTH(date) >= 9 THEN YEAR(date) + 1 ELSE YEAR(date) END = 2021
```

Same result, spelled out explicitly instead of shifted. Ran `EXPLAIN ANALYZE` on both to see whether one is cheaper than the other -- see `fix-query.sql` for the exact statements. Both approaches wrap the `date` column in a function, so neither can use an index on `date` -- worth keeping in mind if this table grows and the query needs to get faster later.

## Result

Trap query: 619,763 rows. Fix query: 608,108 rows -- the difference is exactly the Sep-Dec 2021 rows that don't belong in FY2021.

Full exported result: [Results](./Results)

## Takeaway

-- A query running without errors doesn't mean it's answering the right question. "FY2021" and "calendar year 2021" are not the same range unless the business explicitly runs on a January fiscal year.
-- Check the table for a column that already answers the question before writing logic to compute it yourself.

---

**Original LinkedIn post:** [add link here]
