# SQL-Challenge-Through-One-dataset-Aug-2026


Welcome to my Codebasics "SQL Through One Dataset" Challenge project. This repository features a 15 day query debugging series built entirely on one MySQL dataset, AtliQ Hardware (gdb0041). Each day takes one real business question, breaks down the query trap that produces a wrong or incomplete result, and documents the fix with full reasoning and validated output.

---

## Table of Contents
- [Introduction](#introduction)
- [Project Description](#project-description)
- [Folder Structure](#Folder-Structure)
- [Key Features](#Key-Features)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Introduction
---
*Project Title:* SQL Through One Dataset -- 15 Day Challenge  
*Created By:* [Sachin-Analyst](https://github.com/Sachin-Analyst)  
*Tools Used:* MySQL, MySQL Workbench  
*Focus Areas:* Query Debugging, Filtering Logic, Joins, Window Functions, Query Plan Interpretation  
*Challenge By:* Codebasics -- mentored by Dhaval Patel, Hemanand Vadivel, and Naveen S

---

## Project Description
This repository contains the daily body of work from the Codebasics "SQL Through One Dataset" 15-day challenge.

Each day starts with one business question against the AtliQ Hardware dataset (gdb0041). The first query attempt looks correct and runs without error, but returns wrong or incomplete results because of a specific SQL trap: an under-specified filter, a missing join, a GROUP BY misuse, a window function misapplication, and so on. Each day's folder documents the trap, the fix, the reasoning behind it, and the final validated query.

---

## Folder Structure

| Day | Folder | Focus |
|---|---|---|
| 01 | [Day 1](./Day%201) | Filtering across related tables and joining fact/dimension tables for readable output |
| 02 | [Day 2](./Day%202) | Filtering to the correct fiscal year window using `DATE_ADD` instead of hardcoded date ranges |
| 03 | [Day 3](./Day%203) | Joining fact tables on the right composite key instead of a partial match that fans out rows |
| 04 | [Day 4](./Day%204) | Sorting months in true calendar order instead of the default alphabetical sort |
| 05 | [Day 5](./Day%205) | "Top 5 markets" is two different questions depending on what's being ranked |
| 06 | [Day 6](./Day%206) | Calculating percent of total without collapsing or losing the grand total row |
| 07 | [Day 7](./Day%207) | Net invoice sales is a fraction of gross sales, not a standalone whole number |
| 08 | [Day 8](./Day%208) | Breaking a single dense query into readable CTEs -- why readability isn't just cosmetic |
| 09 | [Day 9](./Day%209) | Two deductions tables, two different grains -- why reusing yesterday's join key silently fans out row counts |
| 10 | [Day_10](./Day_10) | Top 3 products per division using `RANK() OVER (PARTITION BY division)`, instead of one shared top 3 |
| 11 | [Day_11](./Day_11) | Pivoting FY2020 vs FY2021 into columns on one row per market, with a `NULLIF` guard against divide-by-zero |
| 12 | [Day_12](./Day_12) | Running total that resets at each fiscal year boundary, ordered by true date instead of alphabetical month name |
| 13 | [Day_13](./Day_13) | Forecast vs actuals comparison rebuilt with LEFT JOIN + UNION ALL, since INNER JOIN was silently dropping every forecasted-not-sold and sold not forecasted month |
| 14 | [Day_14](./Day_14) | New FY2021 customers list rebuilt with NOT EXISTS, since NOT IN silently returned a false zero the moment a NULL reached its subquery |
| 15 | [Day_15](./Day_15)  | FY2021 top 10 customers by NET sales, built through the full gross-to-net chain with CTEs, then ranked and measured by share of total net sales |

---

## Key Features
- *Query Debugging* - identifying why a query that runs without error still returns the wrong result
- *Trap Identification* - naming the specific SQL misunderstanding behind each day's problem
- *Fix Queries* - validated MySQL queries with a before/after comparison
- *Plain-Language Explanations* - analogies and breakdowns that explain the fix, not just the syntax
- *Real Query Results* - actual row counts and output from each validated fix

## Installation
To explore or modify this project:
1. *Clone the repository:*
```bash
   git clone https://github.com/Sachin-Analyst/SQL-Challenge-Through-One-dataset-Aug-2026.git
```
   - Open terminal and run the command
2. *Download and Open MySQL Workbench* (or any MySQL client)
   - All queries in this series were written and tested in MySQL
3. *Explore Resources*
   - Open any `Day-XX` folder to review the full problem breakdown, trap, and fix query for that day

---

## Usage
### What You Can Explore
- The exact business question asked each day
- The trap query that looks right but returns the wrong result, and why
- The fix query with full explanation
- Real row counts and results from the validated query
----

# Note !
The AtliQ Hardware dataset (gdb0041) used in this challenge is provided by Codebasics as part of the "SQL Through One Dataset" series and is not included in this repository. All logic and results shown are based on that dataset.

----

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
