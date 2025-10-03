-- EDA
SELECT *
FROM bigquery-public-data.cms_medicare.outpatient_charges_2015
LIMIT 10;

SELECT COUNT(*) AS total_rows
FROM bigquery-public-data.cms_medicare.outpatient_charges_2015;

-- top 10 services by number of claims
SELECT apc,
      ROUND(SAFE_DIVIDE(
          SUM(outpatient_services * average_total_payments),
          NULLIF(SUM(outpatient_services), 0)
       ), 2) AS avg_payment_per_claim,
      ROUND(SUM(outpatient_services * average_total_payments), 2) AS total_revenue
FROM bigquery-public-data.cms_medicare.outpatient_charges_2015
GROUP BY apc
ORDER BY avg_payment_per_claim DESC
LIMIT 10;

-- Total medicare spending by state
SELECT provider_state,
      ROUND(AVG(average_total_payments), 2) AS avg_payments_by_state,
      -- average_total_payments column includes deductible and out of pocket, which are typically 15-20% of total payments
      ROUND(SUM(outpatient_services) * AVG(average_total_payments * 0.8), 2) AS proxy_medicare_spending
FROM bigquery-public-data.cms_medicare.outpatient_charges_2015
GROUP BY 1
ORDER BY 3 DESC;

-- Total medicare spending by state VS Total income by state
WITH acs_state AS (
  SELECT
    CASE
      WHEN geo_id = '01' THEN 'AL' WHEN geo_id = '02' THEN 'AK'
      WHEN geo_id = '04' THEN 'AZ' WHEN geo_id = '05' THEN 'AR'
      WHEN geo_id = '06' THEN 'CA' WHEN geo_id = '08' THEN 'CO'
      WHEN geo_id = '09' THEN 'CT' WHEN geo_id = '10' THEN 'DE'
      WHEN geo_id = '11' THEN 'DC' WHEN geo_id = '12' THEN 'FL'
      WHEN geo_id = '13' THEN 'GA' WHEN geo_id = '15' THEN 'HI'
      WHEN geo_id = '16' THEN 'ID' WHEN geo_id = '17' THEN 'IL'
      WHEN geo_id = '18' THEN 'IN' WHEN geo_id = '19' THEN 'IA'
      WHEN geo_id = '20' THEN 'KS' WHEN geo_id = '21' THEN 'KY'
      WHEN geo_id = '22' THEN 'LA' WHEN geo_id = '23' THEN 'ME'
      WHEN geo_id = '24' THEN 'MD' WHEN geo_id = '25' THEN 'MA'
      WHEN geo_id = '26' THEN 'MI' WHEN geo_id = '27' THEN 'MN'
      WHEN geo_id = '28' THEN 'MS' WHEN geo_id = '29' THEN 'MO'
      WHEN geo_id = '30' THEN 'MT' WHEN geo_id = '31' THEN 'NE'
      WHEN geo_id = '32' THEN 'NV' WHEN geo_id = '33' THEN 'NH'
      WHEN geo_id = '34' THEN 'NJ' WHEN geo_id = '35' THEN 'NM'
      WHEN geo_id = '36' THEN 'NY' WHEN geo_id = '37' THEN 'NC'
      WHEN geo_id = '38' THEN 'ND' WHEN geo_id = '39' THEN 'OH'
      WHEN geo_id = '40' THEN 'OK' WHEN geo_id = '41' THEN 'OR'
      WHEN geo_id = '42' THEN 'PA' WHEN geo_id = '44' THEN 'RI'
      WHEN geo_id = '45' THEN 'SC' WHEN geo_id = '46' THEN 'SD'
      WHEN geo_id = '47' THEN 'TN' WHEN geo_id = '48' THEN 'TX'
      WHEN geo_id = '49' THEN 'UT' WHEN geo_id = '50' THEN 'VT'
      WHEN geo_id = '51' THEN 'VA' WHEN geo_id = '53' THEN 'WA'
      WHEN geo_id = '54' THEN 'WV' WHEN geo_id = '55' THEN 'WI'
      WHEN geo_id = '56' THEN 'WY' WHEN geo_id = '72' THEN 'PR'
    END AS state, --FIPS mapping
    total_pop AS population,
    income_per_capita
  FROM bigquery-public-data.census_bureau_acs.state_2015_1yr
),
total_medicare_spending AS (
      SELECT provider_state,
      ROUND(AVG(average_total_payments), 2) AS avg_payments_by_state, -- column "average_total_payments" states the average total payments per claim
      ROUND(SUM(outpatient_services * average_total_payments) *0.8, 2) AS proxy_medicare_spending
      
FROM bigquery-public-data.cms_medicare.outpatient_charges_2015
GROUP BY 1
ORDER BY 3 DESC
)
SELECT t.provider_state,
      t.avg_payments_by_state,
      t.proxy_medicare_spending,
      (a.population * a.income_per_capita) AS total_personal_income,
      ROUND(SAFE_DIVIDE(t.proxy_medicare_spending, NULLIF(a.population * a.income_per_capita, 0)) * 100
  , 4) AS revenue_to_income_pct
FROM total_medicare_spending AS t
JOIN acs_state AS a
ON t.provider_state = a.state
ORDER BY 5 DESC;