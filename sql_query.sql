{\rtf1\ansi\ansicpg1252\cocoartf2709
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww28600\viewh15320\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ============================================================\
-- SECTION 1: Table Creation\
-- ============================================================\
\
CREATE TABLE fashion_data (\
    user_uuid TEXT,\
    category TEXT,\
    designer_id TEXT,\
    language TEXT,\
    level TEXT,\
    country TEXT,\
    purchase_date DATE,\
    platform TEXT,\
    item_id TEXT,\
    stars INTEGER,\
    subscription_date DATE\
);\
\
\
-- ============================================================\
-- SECTION 2: Data Preparation\
-- ============================================================\
\
-- Full dataset view with all time dimensions\
CREATE OR REPLACE VIEW fashion_data_clean AS\
SELECT\
    user_uuid,\
    category,\
    designer_id,\
    language,\
    level,\
    country,\
    purchase_date,\
    TO_CHAR(purchase_date, 'YYYY-MM-DD') AS dt_purchase_date,\
    EXTRACT(YEAR FROM purchase_date)::INT AS purchase_year,\
    EXTRACT(QUARTER FROM purchase_date)::INT AS purchase_quarter,\
    EXTRACT(MONTH FROM purchase_date)::INT AS purchase_month,\
    platform,\
    item_id,\
    stars,\
    subscription_date,\
    TO_CHAR(subscription_date, 'YYYY-MM-DD') AS dt_subscription_date,\
    EXTRACT(YEAR FROM subscription_date)::INT AS subscription_year,\
    EXTRACT(QUARTER FROM subscription_date)::INT AS subscription_quarter\
FROM fashion_data\
ORDER BY purchase_date ASC;\
\
-- 2021 filtered view for annual deep dive\
CREATE OR REPLACE VIEW fashion_data_2021 AS\
SELECT *\
FROM fashion_data_clean\
WHERE purchase_date BETWEEN '2021-01-01' AND '2021-12-31';\
\
\
-- ============================================================\
-- SECTION 3: 2021 Annual Analysis\
-- ============================================================\
\
-- 1. Sales by price tier with percentage and ranking\
WITH sales_per_level AS (\
    SELECT\
        level,\
        COUNT(item_id) AS number_of_sales\
    FROM fashion_data_2021\
    GROUP BY level\
)\
SELECT\
    level,\
    number_of_sales,\
    ROUND(100.0 * number_of_sales / SUM(number_of_sales) OVER (), 2) AS percentage_of_total,\
    RANK() OVER (ORDER BY number_of_sales DESC) AS sales_rank\
FROM sales_per_level\
ORDER BY sales_rank;\
\
\
-- 2. Top 3 countries per price tier by distinct users\
WITH country_level_users AS (\
    SELECT\
        country,\
        level,\
        COUNT(DISTINCT user_uuid) AS number_of_users\
    FROM fashion_data_2021\
    GROUP BY country, level\
)\
SELECT *\
FROM (\
    SELECT\
        country,\
        level,\
        number_of_users,\
        RANK() OVER (PARTITION BY level ORDER BY number_of_users DESC) AS country_rank\
    FROM country_level_users\
) ranked\
WHERE country_rank <= 3\
ORDER BY level, country_rank;\
\
\
-- 3. Sales breakdown by platform and category with share per platform\
WITH platform_sales AS (\
    SELECT\
        platform,\
        category,\
        level,\
        COUNT(item_id) AS number_of_sales\
    FROM fashion_data_2021\
    GROUP BY platform, category, level\
)\
SELECT\
    platform,\
    category,\
    level,\
    number_of_sales,\
    ROUND(100.0 * number_of_sales / SUM(number_of_sales) OVER (PARTITION BY platform), 2) AS share_within_platform\
FROM platform_sales\
ORDER BY platform, number_of_sales DESC;\
\
\
-- 4. Most used platform per price tier with percentage\
WITH platform_level_sales AS (\
    SELECT\
        platform,\
        level,\
        COUNT(item_id) AS number_of_sales\
    FROM fashion_data_2021\
    GROUP BY platform, level\
)\
SELECT\
    platform,\
    level,\
    number_of_sales,\
    ROUND(100.0 * number_of_sales / SUM(number_of_sales) OVER (PARTITION BY level), 2) AS share_within_level\
FROM platform_level_sales\
ORDER BY level, number_of_sales DESC;\
\
\
-- 5. Top selling designer per category in 2021\
WITH designer_sales AS (\
    SELECT\
        category,\
        designer_id,\
        COUNT(item_id) AS total_sales\
    FROM fashion_data_2021\
    GROUP BY category, designer_id\
)\
SELECT *\
FROM (\
    SELECT\
        category,\
        designer_id,\
        total_sales,\
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_sales DESC) AS rn\
    FROM designer_sales\
) ranked\
WHERE rn = 1\
ORDER BY category;\
\
\
-- ============================================================\
-- SECTION 4: RFM Customer Segmentation (Full Dataset)\
-- Segments users into 4 commercial personas based on\
-- purchase frequency and product satisfaction score\
-- ============================================================\
\
WITH user_metrics AS (\
    SELECT\
        user_uuid,\
        COUNT(*) AS total_sales,\
        ROUND(AVG(stars)::numeric, 1) AS avg_stars\
    FROM fashion_data\
    GROUP BY user_uuid\
),\
stats AS (\
    SELECT\
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_sales) AS median_sales,\
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_stars) AS median_stars\
    FROM user_metrics\
),\
clustered AS (\
    SELECT\
        um.user_uuid,\
        um.total_sales,\
        um.avg_stars,\
        CASE\
            WHEN um.total_sales <  s.median_sales AND um.avg_stars <  s.median_stars THEN 'Gabriel'  -- Low purchases, low rating\
            WHEN um.total_sales <  s.median_sales AND um.avg_stars >= s.median_stars THEN 'Emily'    -- Low purchases, high rating\
            WHEN um.total_sales >= s.median_sales AND um.avg_stars <  s.median_stars THEN 'Camille'  -- High purchases, low rating\
            WHEN um.total_sales >= s.median_sales AND um.avg_stars >= s.median_stars THEN 'Sylvie'   -- High purchases, high rating\
        END AS cluster_name\
    FROM user_metrics um\
    CROSS JOIN stats s\
)\
SELECT\
    cluster_name,\
    COUNT(*) AS user_count,\
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_users,\
    ROUND(AVG(total_sales), 2) AS avg_purchases_per_user,\
    ROUND(AVG(avg_stars), 2) AS avg_satisfaction_score\
FROM clustered\
GROUP BY cluster_name\
ORDER BY cluster_name;\
\
\
-- ============================================================\
-- SECTION 5: Year-over-Year Sales Growth by Category\
-- Tracks sell-through trend across 2021, 2022, 2023\
-- ============================================================\
\
WITH yearly_sales AS (\
    SELECT\
        category,\
        purchase_year,\
        COUNT(item_id) AS total_sales\
    FROM fashion_data_clean\
    GROUP BY category, purchase_year\
),\
yoy AS (\
    SELECT\
        category,\
        purchase_year,\
        total_sales,\
        LAG(total_sales) OVER (PARTITION BY category ORDER BY purchase_year) AS prev_year_sales\
    FROM yearly_sales\
)\
SELECT\
    category,\
    purchase_year,\
    total_sales,\
    prev_year_sales,\
    CASE\
        WHEN prev_year_sales IS NULL THEN NULL\
        ELSE ROUND(100.0 * (total_sales - prev_year_sales) / prev_year_sales, 2)\
    END AS yoy_growth_pct\
FROM yoy\
ORDER BY category, purchase_year;\
\
\
-- ============================================================\
-- SECTION 6: Cohort Retention Analysis\
-- Tracks repeat purchase rate by acquisition month\
-- ============================================================\
\
WITH first_purchase AS (\
    SELECT\
        user_uuid,\
        DATE_TRUNC('month', MIN(purchase_date)) AS cohort_month\
    FROM fashion_data\
    GROUP BY user_uuid\
),\
user_activity AS (\
    SELECT\
        f.user_uuid,\
        fp.cohort_month,\
        DATE_TRUNC('month', f.purchase_date) AS activity_month,\
        (\
            EXTRACT(YEAR FROM DATE_TRUNC('month', f.purchase_date)) -\
            EXTRACT(YEAR FROM fp.cohort_month)\
        ) * 12 +\
        (\
            EXTRACT(MONTH FROM DATE_TRUNC('month', f.purchase_date)) -\
            EXTRACT(MONTH FROM fp.cohort_month)\
        ) AS months_since_acquisition\
    FROM fashion_data f\
    JOIN first_purchase fp ON f.user_uuid = fp.user_uuid\
),\
cohort_size AS (\
    SELECT cohort_month, COUNT(DISTINCT user_uuid) AS cohort_users\
    FROM first_purchase\
    GROUP BY cohort_month\
)\
SELECT\
    TO_CHAR(ua.cohort_month, 'YYYY-MM') AS cohort,\
    cs.cohort_users,\
    ua.months_since_acquisition AS month_number,\
    COUNT(DISTINCT ua.user_uuid) AS retained_users,\
    ROUND(100.0 * COUNT(DISTINCT ua.user_uuid) / cs.cohort_users, 1) AS retention_rate_pct\
FROM user_activity ua\
JOIN cohort_size cs ON ua.cohort_month = cs.cohort_month\
WHERE ua.months_since_acquisition BETWEEN 0 AND 12\
GROUP BY ua.cohort_month, cs.cohort_users, ua.months_since_acquisition\
ORDER BY ua.cohort_month, ua.months_since_acquisition;\
\
\
-- ============================================================\
-- SECTION 7: Churn Risk Segmentation\
-- Flags users by days since last purchase\
-- High Risk: 180+ days | Medium: 90-180 days | Active: <90 days\
-- ============================================================\
\
WITH last_purchase AS (\
    SELECT\
        user_uuid,\
        MAX(purchase_date) AS last_purchase_date,\
        COUNT(item_id) AS total_purchases,\
        ROUND(AVG(stars)::numeric, 1) AS avg_rating\
    FROM fashion_data\
    GROUP BY user_uuid\
),\
dataset_max_date AS (\
    SELECT MAX(purchase_date) AS max_date FROM fashion_data\
)\
SELECT\
    lp.user_uuid,\
    lp.last_purchase_date,\
    lp.total_purchases,\
    lp.avg_rating,\
    (dm.max_date - lp.last_purchase_date) AS days_since_last_purchase,\
    CASE\
        WHEN (dm.max_date - lp.last_purchase_date) > 180 THEN 'High Churn Risk'\
        WHEN (dm.max_date - lp.last_purchase_date) > 90  THEN 'Medium Churn Risk'\
        ELSE 'Active'\
    END AS churn_risk_segment\
FROM last_purchase lp\
CROSS JOIN dataset_max_date dm\
ORDER BY days_since_last_purchase DESC;\
\
\
-- ============================================================\
-- SECTION 8: AOV Proxy \'97 Avg Purchases per User by Country & Price Tier\
-- Note: no price column in dataset \'97 purchase frequency used as proxy\
-- ============================================================\
\
SELECT\
    country,\
    level AS price_tier,\
    COUNT(item_id) AS total_transactions,\
    COUNT(DISTINCT user_uuid) AS unique_buyers,\
    ROUND(COUNT(item_id)::numeric / COUNT(DISTINCT user_uuid), 2) AS aov_proxy,\
    ROUND(AVG(stars)::numeric, 2) AS avg_satisfaction_score,\
    ROUND(100.0 * COUNT(item_id) / SUM(COUNT(item_id)) OVER (PARTITION BY country), 2) AS pct_within_country\
FROM fashion_data\
GROUP BY country, level\
ORDER BY country, total_transactions DESC;}