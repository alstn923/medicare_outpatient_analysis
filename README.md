# SQL Project: Medicare Outpatient Payments Analysis (2015)

## 📖 Overview
This project analyzes the **2015 CMS Medicare Outpatient Charges dataset** using **SQL (BigQuery)**.  
The goal is to:
- Explore outpatient service utilization patterns
- Compare provider payments across states
- Estimate proxy Medicare payments (assuming 80% Medicare / 20% out-of-pocket split)
- Evaluate the relative economic footprint of hospital spending versus state total income

---

## 🛠️ Data

- **CMS Medicare Public Data**  
  - Table: `bigquery-public-data.cms_medicare.outpatient_charges_2015`  
- **U.S. Census Bureau ACS (2015)**  
  - Table: `bigquery-public-data.census_bureau_acs.state_2015_1yr`  

⚠️ Note: `average_total_payments` includes Medicare payments **plus** patient cost-sharing (deductible/copay).  
To approximate Medicare-only payments, a **0.8 multiplier (80%)** is applied as a proxy assumption.

---

## 🔍 Analysis Steps

1. **Exploratory Data Analysis (EDA)**  
   - Previewed table schema and row counts  

2. **Top Outpatient Services (APC codes)**  
   - Identified top 10 services by claim volume  
   - Calculated weighted average payment per claim  

3. **State-Level Proxy Medicare Spending**  
   - Computed weighted averages and proxy Medicare payments  

4. **Spending vs Total Income**  
   - Estimated total personal income = population × income per capita  
   - Compared proxy Medicare spending as % of total income  

---

## 🧾 Example Queries

### 1. Exploratory Data Analysis
```sql
SELECT *
FROM `bigquery-public-data.cms_medicare.outpatient_charges_2015`
LIMIT 10;

SELECT COUNT(*) AS total_rows
FROM `bigquery-public-data.cms_medicare.outpatient_charges_2015`;
