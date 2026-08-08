# Day 10 / 15 -- Top 3 Per Division, Not Top 3 Overall

**Dataset:** AtliQ Hardware (`gdb0041`) | **Tool:** MySQL | **Date:** 05/08/2026

[View fix-query.sql](./fix-query.sql)

---

## The Ask

![Codebasics ask on Discord](./assets/challenge/discord-ask.png)

Day 10 of 15, same dataset (AtliQ Hardware, `gdb0041`) as every other day in this series.

AtliQ runs three divisions -- P & A, PC, and N & S. Leadership wants the top 3 products by quantity sold, but in EACH division, not across the company as a whole.

Today's question: return the top 3 products within each of the three divisions.

## The Trap

The obvious move is to sort every product by `total_sold_quantity` and slap a `LIMIT 3` on it.

That gets 3 products, and all 3 come from P & A. PC and N & S vanish completely. `LIMIT` trims the whole result set from the top -- it has no idea divisions exist, so it can't restart the count once it crosses into a new one. If one division happens to sell more volume overall, it eats every single slot before the other two even get considered.

## The Fix

Split the rows by division first, then rank inside each split:

```sql
RANK() OVER (PARTITION BY division ORDER BY SUM(fsm.sold_quantity) DESC) AS product_rank
```

`PARTITION BY division` resets the ranking for every division on its own. `ORDER BY` decides the order inside that reset. Filter on `product_rank <= 3` afterward and each division keeps its own top 3, instead of competing for a single shared podium.

## Why It Works

Same idea as an exam result, four stages deep: one single merit list ranks every student against the whole school (that's `ORDER BY` + `LIMIT`) and only the highest scorers anywhere make it, no matter which section they're in. Split by section instead -- 10-A, 10-B, 10-C graded separately -- and each section produces its own toppers, a podium per section rather than one podium for the entire school. Three sections times three toppers gives nine names on the final report card, not three. Same reasoning applies here: `PARTITION BY division` is the split into sections, `RANK() OVER()` is the podium per section, and the final `SELECT` is the report card.

## Fix Query

```sql
WITH ranked_products_report AS (
SELECT 
	dp.product_code , dp.product , dp.division, 
	SUM(fsm.sold_quantity) total_sold_quantity,
	RANK() OVER (PARTITION BY division ORDER BY SUM(fsm.sold_quantity) DESC ) AS product_rank
FROM fact_sales_monthly fsm 
	JOIN dim_product dp
		ON fsm.product_code = dp.product_code
GROUP BY dp.division , dp.product_code )
    
SELECT 
rpp.product_code , rpp.product , 
rpp.division , rpp.total_sold_quantity, rpp.product_rank
 FROM ranked_products_report rpp
    WHERE product_rank <=3
    ORDER BY rpp.division , rpp.product_rank;
```

Full file: [fix-query.sql](./fix-query.sql)

## Result

Three divisions, three products each -- 9 rows total, exactly what the ask called for. A preview:

| product_code | product | division | total_sold_quantity | product_rank |
|---|---|---|---|---|
| A6720160103 | AQ Pen Drive 2 IN 1 | N & S | 1332238 | 1 |
| A6818160201 | AQ Pen Drive DRC | N & S | 1300534 | 2 |
| A6319160201 | AQ Neuer SSD | N & S | 1207499 | 3 |
| A2118150106 | AQ Master wired x1 Ms | P & A | 1216615 | 1 |
| A2118150105 | AQ Master wired x1 Ms | P & A | 1210759 | 2 |
| A2219150203 | AQ Master wireless x1 Ms | P & A | 1210271 | 3 |
| A4218110202 | AQ Digit | PC | 56791 | 1 |
| A4118110107 | AQ Aspiron | PC | 56363 | 2 |
| A4218110201 | AQ Digit | PC | 56149 | 3 |

Full exported result: [Results](./Results)

## Takeaway

-- `LIMIT` alone has no concept of groups. It trims the final result set top-down, so one large division can crowd out every other division before ranking ever gets a chance to run per group.
-- `PARTITION BY` is what resets the count. Reach for it any time "top N per group" shows up in the ask, instead of trying to fix it after the fact with filters or extra `LIMIT` clauses.

---

**Original LinkedIn post:** [add link here]
**Dataset reference (Codebasics course):** https://codebasics.io/courses/bootcamp/1/sql-beginner-to-advanced-for-data-professionals/lecture/1070
