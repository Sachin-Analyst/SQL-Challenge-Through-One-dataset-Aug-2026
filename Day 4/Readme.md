# Day 4 / 15 -- Sorting Months in Calendar Order, Not Alphabetical

**Dataset:** AtliQ Hardware (`gdb0041`) | **Tool:** MySQL | **Date:** 30/07/2026

[View fix-query.sql](./fix-query.sql)

---

## The Ask

![Codebasics ask on Discord](./assets/challenge/discord-ask.png)

Day 4 of 15, same dataset (AtliQ Hardware, `gdb0041`) as every other day in this series.

The relevant table: `fact_sales_monthly` (`sold_quantity`).

Report needed: monthly gross sales for Atliq E Store, India, FY 2021. The manager wants the oldest month first, and each month listed once.

## The Trap

The obvious first move is to sort directly on the readable month name:

```sql
ORDER BY MONTHNAME(fsm.date)
```

This runs clean, no errors. The problem is that `MONTHNAME()` returns text, and MySQL sorts text alphabetically, not by calendar position. That puts April before January, sorts August second, and puts December third -- alphabetical order, not chronological order.

## The Fix

Group and sort on the underlying numeric year and month, and keep `MONTHNAME()` only for the column that gets displayed:

```sql
GROUP BY YEAR(fsm.date), MONTH(fsm.date), MONTHNAME(fsm.date)
ORDER BY YEAR(fsm.date), MONTH(fsm.date);
```

The output still shows readable month names, but the row order now follows the actual calendar, oldest month first.

## Bonus Find: The Market Filter Still Matters

Fixing the sort isn't the whole story here. Atliq E Store is the same customer name across 24 different markets -- the same trap as Day 1, hiding underneath a completely different bug.

-- Without the `dc.market = 'India'` filter: 12 rows, all 24 markets blended together
-- With the filter: 9 rows, correctly scoped to India only

A query can be fixed in one clause and still be wrong in another.

## Why It Works

Same idea as sorting a weekend list by name instead of by day: text order puts "Friday" ahead of "Monday" alphabetically, while calendar order correctly puts Monday first. A month's name doesn't carry its position in the calendar -- only the actual year and month numbers do. Order isn't the same thing as alphabet.

## Fix Query

```sql
SELECT 
    fsm.fiscal_year,
    MONTHNAME(fsm.date) sales_month_name,
    CONCAT(ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2),' Mln') gross_sales_mln
FROM gdb0041.fact_sales_monthly fsm
JOIN dim_customer dc
    ON dc.customer_code = fsm.customer_code
JOIN dim_product dp
    ON dp.product_code = fsm.product_code
JOIN fact_gross_price fgp
    ON fgp.product_code = fsm.product_code 
    AND fgp.fiscal_year = fsm.fiscal_year
WHERE 
    dc.customer = 'Atliq E store' 
    AND fsm.fiscal_year = 2021 
    AND dc.market = 'India'
GROUP BY YEAR(fsm.date), MONTH(fsm.date), MONTHNAME(fsm.date)
ORDER BY YEAR(fsm.date), MONTH(fsm.date);
```

Full file: [fix-query.sql](./fix-query.sql)

## Result

9 rows returned, in correct chronological order for FY2021:

| fiscal_year | sales_month_name | gross_sales_mln |
|---|---|---|
| 2021 | September | 2.37 Mln |
| 2021 | October | 3.03 Mln |
| 2021 | December | 4.08 Mln |
| 2021 | January | 2.31 Mln |
| 2021 | February | 2.39 Mln |
| 2021 | April | 2.26 Mln |
| 2021 | May | 2.27 Mln |
| 2021 | June | 2.23 Mln |
| 2021 | August | 2.40 Mln |

Full exported result: [Results](./Results)

## Takeaway

-- `ORDER BY` on a function like `MONTHNAME()` sorts by whatever that function returns -- text in this case -- not by what the text represents. Sort on the underlying numeric value, and keep the readable version for display only.
-- Fixing one trap doesn't clear a query of every trap. The same customer-name-across-markets issue from Day 1 can hide underneath a completely unrelated sorting bug.

---

**Original LinkedIn post:** [add link here]
