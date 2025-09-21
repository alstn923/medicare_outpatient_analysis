# SQL Project 1: Medicare Outpatient Payments Analysis (2015)

## 📖 Overview
This project analyzes the **2015 CMS Medicare Outpatient Charges dataset** using **SQL (BigQuery)**.  
The goal is to:
- Explore outpatient service utilization patterns
- Compare provider payments across states
- Evaluate the relative economic footprint of hospital spending versus state total income

This project is designed as part of my analytics portfolio.

---

## 🛠️ Data

- **CMS Medicare Public Data**  
  - Table: `bigquery-public-data.cms_medicare.outpatient_charges_2015`  
- **U.S. Census Bureau ACS (2015)**  
  - Table: `bigquery-public-data.census_bureau_acs.state_2015_1yr`  

📂 A small sample CSV file is included here for demonstration:  
[`data/outpatient_charges_2015_sample.csv`](data/outpatient_charges_2015_sample.csv)

---

## 🔍 Analysis Steps

1. **Exploratory Data Analysis (EDA)**  
   - Checked table schema, row counts, sample records  

2. **Top Outpatient Services (APC codes)**  
   - Identified top 10 APCs by claim volume  
   - Calculated total payments and weighted average payment per claim  

3. **State-Level Spending**  
   - Computed total and average payments per claim by provider state  

4. **Spending vs State Total Income**  
   - Estimated state-level total income = population × income per capita  
   - Compared hospital outpatient payments as a % of total income  

---

## 🧾 Example Queries

### Top 10 APCs by Number of Claims
```sql
SELECT
  apc,
  SUM(outpatient_services) AS num_claims,
  ROUND(SAFE_DIVIDE(
          SUM(outpatient_services * average_total_payments),
          NULLIF(SUM(outpatient_services), 0)
       ), 2) AS avg_payment_per_claim,
  ROUND(SUM(outpatient_services * average_total_payments), 2) AS total_payments
FROM `bigquery-public-data.cms_medicare.outpatient_charges_2015`
GROUP BY apc
ORDER BY num_claims DESC
LIMIT 10;
