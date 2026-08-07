# Day 3 / 15 -- Joining on the Right Composite Key

**Dataset:** AtliQ Hardware (`gdb0041`) | **Tool:** MySQL | **Date:** 29/07/2026

[View fix-query.sql](./fix-query.sql)

---

## The Ask

![Codebasics ask on Discord](./assets/challenge/discord-ask.png)

Day 3 of 15, same dataset (AtliQ Hardware, `gdb0041`) as every other day in this series.

The relevant tables this time:

-- `fact_sales_monthly` -- `sold_quantity`, `product_code`, `fiscal_year`
-- `fact_gross_price` -- `product_code`, `fiscal_year`, `gross_price`

The manager's ask: **gross sales in money, not units.** That means `sold_quantity` needs to be multiplied by the correct `gross_price` for each row.

## The Trap

The obvious first move is to join the two tables on `product_code` alone:

```sql
JOIN gdb0041.fact_gross_price gp
    ON fs.product_code = gp.product_code
```

This runs clean, no errors. The problem is that `gross_price` isn't fixed per product -- it changes across fiscal years for the same `product_code`:

-- FY2020 price: ₹90
-- FY2021 price: ₹100
-- FY2022 price: ₹150

Joining on `product_code` only means one sales row can match all three of those price rows at once, instead of the one price that was actually valid the year that sale happened. Gross sales ends up calculated against the wrong price, or duplicated across every year the product ever had a price.

## The Fix

Join on both `product_code` and `fiscal_year` together:

```sql
ON fs.product_code = gp.product_code
    AND fs.fiscal_year = gp.fiscal_year
```

Now each sales row matches exactly the price that was valid in that specific fiscal year -- nothing more, nothing less.

## Bonus Find: GROUP BY Hides a Trap Too

Fixing the join alone isn't the full picture. `fact_sales_monthly` has one row per month, so without a `GROUP BY fs.product_code, fs.fiscal_year`, the query still returns one row per month instead of one aggregated gross sales figure per product per year. Correct join, wrong grain -- `GROUP BY` is what turns individual matched rows into the actual answer the manager asked for.

## Why It Works

Same idea as petrol prices: same fuel, but ₹102.63 in 2023 and ₹107.77 in 2026. Same product, different year, different price -- price was never fixed to the product alone.

`gross_price` works the same way here. It belongs to `product_code` AND `fiscal_year` together, not `product_code` in isolation. Joining on only one half of that pair is what let the wrong price sneak in.

## Fix Query

```sql
SELECT 
    fs.product_code,
    fs.fiscal_year,
    ROUND(SUM(fs.sold_quantity * gp.gross_price) / 1000000, 2) AS gross_sales_mln
FROM gdb0041.fact_sales_monthly fs
JOIN gdb0041.fact_gross_price gp
    ON fs.product_code = gp.product_code
    AND fs.fiscal_year = gp.fiscal_year
GROUP BY fs.fiscal_year, fs.product_code;
```

Full file: [fix-query.sql](./fix-query.sql)

## Result

Sample of the output, gross sales in millions of rupees per product per fiscal year:

| product_code | fiscal_year | gross_sales_mln |
|---|---|---|
| A0118150101 | 2018 | 0.29 |
| A0118150102 | 2018 | 0.35 |
| A0118150103 | 2018 | 0.36 |
| A0418150101 | 2018 | 0.35 |
| A0418150102 | 2018 | 0.37 |

Full exported result: [Results](./Results)

## Takeaway

-- A join that "runs clean" can still silently mismatch or multiply values if the join key is missing part of the composite key. Check whether the column you're pulling from the right-hand table actually varies by more than the one column you joined on.
-- `GROUP BY` isn't only for totals -- it's what stops a correctly joined row from getting counted at the wrong grain.

---

**Original LinkedIn post:** [add link here]
