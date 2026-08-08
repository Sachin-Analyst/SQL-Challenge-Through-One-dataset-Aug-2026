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

- *Day 1 / 15 -- Filtering Across Related Tables*
- *Day 2 / 15 -- Fiscal Year Filtering with DATE_ADD*
- *Day 3 / 15 -- Joining on the Right Composite Key*
- *Day 4 / 15 -- Sorting Months in Calendar Order, Not Alphabetical*
- *Day 5 / 15 -- "Top 5 Markets" Is Two Different Questions*
- *Day 6 / 15 -- Percent of Total Without Losing the Grand Total*
- *Day 7 / 15 -- Net Invoice Sales: a Fraction, Not a Whole Number*
- *Day 8 / 15 -- Readability Is Not Cosmetic*
- *Day 9 / 15 -- Two Deductions Tables, Two Different Grains*
- *Day 10 / 15 -- Top 3 Per Division, Not Top 3 Overall*
- *Day 11 / 15 -- Two Years, One Row: Pivoting FY2020 vs FY2021*
- *Day 12 / 15 -- A Running Total That Resets on Its Own Calendar*
- *Day 13/15 -- Will be uploaded*
- *Day 14/15 -- Will be uploaded*
- *Day 15/15 -- Will be uploaded*

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
