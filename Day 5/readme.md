# Day 5 / 15 -- "Top 5 Markets" Is Two Different Questions

**Dataset:** AtliQ Hardware (`gdb0041`) | **Tool:** MySQL | **Date:** 31/07/2026

[Fix-query-01](./Day-5-Fix-query.sql)

---

## The Ask

![Codebasics ask on Discord](./assets/challenge/discord-ask.png)

Day 5 of 15, same dataset (AtliQ Hardware, `gdb0041`) as every other day in this series.

Tables involved: `fact_sales_monthly`, `dim_customer`, `fact_gross_price`.

Report needed: top 5 markets by gross sales, FY 2021. The manager wants "the list."

## Two Valid Interpretations

Unlike most days in this series, there's no single query that's flat-out wrong here. Two different approaches both look correct:

-- **Row count = 5** -- always return exactly 5 rows (`LIMIT 5`)
-- **RANK <= 5** -- return every row that ranks within the top 5 (`RANK() <= 5`)

Both are valid, until a tie shows up. They only produce different results the moment two markets tie for 5th place.

## Approach 1: RANK() <= 5

```sql
RANK() OVER (ORDER BY SUM(fsm.sold_quantity * fgp.gross_price) DESC) AS rnk
...
WHERE rnk <= 5
```

Returns every market whose rank falls within the top 5. If two markets tie for 5th, both get included -- so the result could be 5 rows, 6, or more, depending on how many-way the tie is.

## Approach 2: LIMIT 5

```sql
ORDER BY gsr.gross_sales_mln DESC
LIMIT 5
```

Always returns exactly 5 rows, tie or no tie. If two markets tie for 5th, `LIMIT` picks one of them based on whatever order MySQL happens to return ties in -- not a guaranteed or meaningful choice unless a tiebreaker column is added to the `ORDER BY`.

## Why It Works

Same idea as a running race where two runners cross the line at the exact same time for 5th place. Do you hand out exactly 5 medals, arbitrarily picking one of the two tied runners? Or 6 medals, because both of them genuinely finished 5th? `LIMIT 5` behaves like the first option, `RANK() <= 5` behaves like the second. `LIMIT` is not the same thing as `RANK`.

## Fix Queries

**RANK() version:**
```sql
WITH gross_sales_report AS (
SELECT 
    fsm.fiscal_year,
    ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2) gross_sales_mln,
    dc.market,
    RANK() OVER (ORDER BY SUM(fsm.sold_quantity * fgp.gross_price) DESC) AS rnk
FROM gdb0041.fact_sales_monthly fsm
JOIN dim_customer dc
    ON dc.customer_code = fsm.customer_code
JOIN fact_gross_price fgp
    ON fgp.product_code = fsm.product_code 
    AND fgp.fiscal_year = fsm.fiscal_year
WHERE fsm.fiscal_year = 2021 
GROUP BY dc.market)

SELECT 
gsr.fiscal_year, gsr.market, gsr.gross_sales_mln, gsr.rnk
FROM gross_sales_report gsr
WHERE rnk <= 5
ORDER BY rnk;
```

**LIMIT version:**
```sql
WITH gross_sales_report AS (
SELECT 
    fsm.fiscal_year,
    ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2) gross_sales_mln,
    dc.market
FROM gdb0041.fact_sales_monthly fsm
JOIN dim_customer dc
    ON dc.customer_code = fsm.customer_code
JOIN fact_gross_price fgp
    ON fgp.product_code = fsm.product_code 
    AND fgp.fiscal_year = fsm.fiscal_year
WHERE fsm.fiscal_year = 2021 
GROUP BY dc.market)

SELECT gsr.fiscal_year, gsr.market,
gsr.gross_sales_mln
FROM gross_sales_report gsr
ORDER BY gsr.gross_sales_mln DESC
LIMIT 5;
```

Full file: [Fix-query-01](./Day-5-Fix-query.sql)

## Result

FY2021 has no tie at the 5th-place boundary, so both approaches return the identical 5 markets:

| fiscal_year | market | gross_sales_mln | rnk |
|---|---|---|---|
| 2021 | India | 455.05 | 1 |
| 2021 | USA | 264.46 | 2 |
| 2021 | South Korea | 131.86 | 3 |
| 2021 | Canada | 89.78 | 4 |
| 2021 | Philippines | 80.64 | 5 |

The two queries agree here only because this particular dataset happens to have no tie -- that won't hold for every fiscal year or every dataset.

Full exported result: [
Results-01](./Day-5-Results-01.csv)
[Results-02](./Day-5-Results-02.csv)

## Takeaway

-- `LIMIT 5` and `RANK() <= 5` are not interchangeable. They look identical whenever there's no tie in the data, and diverge the moment there is one.
-- Before writing "top N" anything, confirm what's actually wanted: exactly N rows no matter what, or every row that ranks within the top N even if that ends up being more than N.

---

**Original LinkedIn post:** [Linkedin-post-URL](https://www.linkedin.com/posts/vishnu-ram-sachin-d-_day-5-learnings-by-sachin-activity-7488925210570543104-qz1F?utm_source=share&utm_medium=member_desktop&rcm=ACoAAD-YjK4B1ekkuKaP0cSvVwYi6kAAiCTAQhY)
