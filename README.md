# Customer Segmentation & Commercial Analytics — E-commerce Platform

---

## Tools & Skills

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?style=flat&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=flat&logo=python&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-Dashboard-E97627?style=flat&logo=tableau&logoColor=white)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?style=flat&logo=jupyter&logoColor=white)

**SQL:** CTEs · Window Functions · RANK() · PERCENTILE_CONT · YoY Analysis · Cohort Analysis · RFM Scoring  
**Python:** Pandas · NumPy · Seaborn · Matplotlib · Plotly · SciPy · Customer Segmentation  
**Tableau:** Interactive Dashboards · KPI Cards · Geo Maps · Trend Analysis · Filters

---

## Core Commercial Metrics

`AOV` · `GMV` · `LTV` · `Churn Risk` · `Retention Rate` · `Sell-through Rate` · `RFM Segmentation` · `YoY Growth` · `Cohort Analysis` · `Seasonal Trend`

---

## Executive Summary

An e-commerce platform operating across 3 European markets (IT, UK, FR) was experiencing **unclear customer segmentation and no visibility into churn risk or seasonal demand patterns** — making it difficult to prioritise marketing spend and inventory investment.

Using SQL, Python, and Tableau, I analysed **999 transactions from 241 unique users over 3 years (2021–2023)** to identify which customer segments drive the most value, where churn risk is highest, and how seasonality affects category performance.

**Key impact:** Premium-tier customers represent **43.3% of all transactions** and Italy is the top market with **45.1% of users** — but **78 users (32% of the base) are at high churn risk** (180+ days inactive). The highest-LTV segment (Sylvie) shows an avg LTV proxy of 18.18. Q3 consistently drives peak sales volume, with Belts as the top sell-through category at **33.9% of all transactions**.

**Next steps:** Implement RFM-based re-engagement campaigns for the 78 high-churn-risk users, increase Belt and Shoe inventory ahead of Q3, and run A/B tests on retention copy for dormant Italian Premium users.

---

## Business Problem

The commercial team lacked a structured view of customer behaviour across markets and price tiers. Three specific questions were driving the analysis:

1. **Segmentation:** Which customers generate the most value, and how do we retain them?
2. **Churn:** Which users are at risk of churning, and when did they disengage?
3. **Seasonality:** Which categories and markets should we prioritise for inventory planning?

Without answers to these questions, marketing budgets were being allocated broadly rather than to the highest-value segments, and inventory decisions were reactive rather than data-driven.

---

## Methodology

**Phase 1 — SQL: Data Preparation & Segmentation**
- Structured and cleaned raw transaction data in PostgreSQL
- Built analytical views for yearly, quarterly, and monthly breakdowns
- Performed **RFM-based customer clustering** (Recency · Frequency · Rating) using CTEs and window functions
- Added **YoY growth analysis** to track category performance across 2021–2023
- Built **cohort retention analysis** to track repeat purchase rates by acquisition month
- Flagged **churn risk segments** (High / Medium / Active) based on days since last purchase

**Phase 2 — Python: EDA & Insight Generation**
- Cleaned and transformed data (date parsing, feature engineering, null validation)
- Analysed sales trends across category, platform, country, price tier, and time
- Calculated key commercial metrics: AOV proxy, GMV proxy, LTV proxy, sell-through rate, churn risk, retention rate
- Built and visualised 4 RFM customer personas with actionable profiles

**Phase 3 — Tableau: Commercial Dashboards**
- Built two interactive dashboards: full-period overview (2021–2023) and 2021 annual deep dive
- KPIs: transactions by tier, platform share, geo distribution, category performance, seasonal trend
- Enabled stakeholder self-service with interactive filters (country, platform, price tier, date range)

---

## Metrics & Proxy Methodology

This dataset contains transaction records without a price column. The following commercial metrics were calculated using proxy approaches — a standard practice when working with incomplete real-world data.

| Commercial Metric | Standard Definition | Proxy Used in This Project | Why |
|---|---|---|---|
| **AOV** (Avg Order Value) | Revenue / Transactions | Avg purchases per user per period | No price column in dataset |
| **GMV** | Total transaction value | Transaction count weighted by price tier | Price tier (premium/avg/cheap) used as value signal |
| **LTV** (Customer Lifetime Value) | Revenue x retention rate | Purchase frequency x satisfaction score | Satisfaction (stars) used as quality/retention proxy |
| **Retention Rate** | Returning users / Total users | Cohort repeat purchase rate by month | Calculated via cohort analysis in SQL |
| **Churn Risk** | Users below revenue threshold | Days since last purchase (180+/90+/<90) | Industry-standard recency threshold |
| **Sell-through Rate** | Units sold / Units available | Category % of total transactions | No inventory data available |

> **Note:** All proxy metrics are clearly labelled throughout the SQL queries and Python notebook. In a production environment with revenue data, these would be replaced with exact calculations.

---

## Skills Used

| Tool | Techniques |
|---|---|
| **SQL** | CTEs, Window Functions, RANK(), ROW_NUMBER(), PERCENTILE_CONT, LAG(), YoY Growth, Cohort Analysis, RFM Scoring, Churn Flagging |
| **Python** | Pandas, NumPy, Seaborn, Matplotlib, Plotly, SciPy, Customer Segmentation, Seasonal Decomposition |
| **Tableau** | KPI Cards, Geo Map, Bar/Line/Pie Charts, Cross-tab Tables, Interactive Filters, Dashboard Design |

---

## Results & Business Recommendations

### Tableau Dashboards

| Full Period Overview (2021–2023) | 2021 Annual Deep Dive |
|---|---|
| ![General Dashboard](images/dashboard_general.png) | ![2021 Dashboard](images/dashboard_2021.png) |

---

### Python Analytics — Commercial Metrics

| Churn Risk Segmentation | LTV Proxy by RFM Segment |
|---|---|
| ![Churn Risk](images/churn_risk.png) | ![LTV Proxy](images/ltv_proxy.png) |

| AOV Proxy by Country & Price Tier | GMV Proxy by Market & Category |
|---|---|
| ![AOV Proxy](images/aov_proxy.png) | ![GMV Proxy](images/gmv_proxy.png) |

| Sell-through Rate by Category (2021–2023) | Cohort Retention Rate |
|---|---|
| ![Sell-through](images/sell_through.png) | ![Retention Cohort](images/retention_cohort.png) |

---

### Finding 1 — Premium segment drives 43.3% of all transactions
Premium-tier customers account for **43.3% of total purchases**, outperforming Cheap (33.2%) and Average (23.4%) tiers. Italy (45.1% of users) has the highest Premium user concentration with an AOV proxy of **1.46 avg purchases per user** — the highest across all country-tier segments.

**Recommendation:** Launch a loyalty or early-access programme targeting Italian Premium users. This is the highest-AOV and highest-LTV segment and the top retention priority.

---

### Finding 2 — RFM segmentation identifies 4 commercial personas; Sylvie drives highest LTV (18.18)

| Cluster | Profile | % Users | Avg LTV Proxy | Commercial Strategy |
|---|---|---|---|---|
| **Sylvie** | High purchases, high rating | 32.4% | 18.18 | Retain & reward — highest LTV |
| **Camille** | High purchases, low rating | 24.9% | 14.83 | Improve satisfaction — churn risk |
| **Emily** | Low purchases, high rating | 24.5% | 8.25 | Activate — satisfied but underengaged |
| **Gabriel** | Low purchases, low rating | 18.3% | 4.89 | Re-engage with incentive or deprioritise |

**Recommendation:** Focus CRM on **Emily** activation (personalised recommendations) and **Camille** satisfaction recovery (post-purchase follow-up). Combined, these two segments represent 49% of users with clear uplift potential. Sylvie's LTV proxy is **3.7x higher** than Gabriel's — protecting this segment is the single highest-value retention action.

---

### Finding 3 — 58.1% of users are at churn risk; 78 users inactive 180+ days
Churn risk analysis shows only **41.9% of users (101) are active** (<90 days since last purchase). A further **25.7% (62 users)** are at medium churn risk and **32.4% (78 users)** are at high churn risk (180+ days inactive).

**Recommendation:** Immediate re-engagement campaign targeting the 78 high-churn-risk users — personalised email with category recommendations based on their past purchase history. Priority focus on users in the Sylvie and Camille segments who have gone dormant.

---

### Finding 4 — Belts dominate GMV (44.7% of Italy's weighted transactions) and sell-through (33.9%)
Belts are the top category by both sell-through rate (33.9% of all transactions) and GMV proxy. Italy accounts for **44.7% of total GMV proxy**, driven primarily by Belt and Shoe purchases in the Premium tier.

**Recommendation:** Increase Belt and Shoe inventory depth before Q3 peak. Negotiate supplier priority for these SKUs — they represent the platform's highest-GMV categories and stockouts would directly impact revenue.

---

### Finding 5 — Sell-through trend shows Belts and Shoes growing; Dresses and Underwear declining
YoY sell-through analysis (2021→2023) shows Belts maintaining dominance (~30–34%), Shoes and Bottoms growing steadily, while Dresses and Underwear show a consistent declining trend.

**Recommendation:** Shift inventory investment toward Belts, Shoes, and Bottoms. Flag Dresses and Underwear for a markdown or clearance strategy to recover GMV from declining categories.

---

### Finding 6 — Cohort retention averages 20–35% in months 1–3; spikes up to 67% in specific cohorts
Cohort analysis shows that most acquisition cohorts retain 20–35% of users in the first 3 months. The June 2021 cohort shows an exceptional 67% retention at month 2 — a potential benchmark for re-engagement tactics.

**Recommendation:** Analyse what drove the June 2021 cohort's 67% month-2 retention — if tied to a specific campaign or season, replicate it. Target months 1–3 post-acquisition as the critical retention window with automated onboarding sequences.

---

### Finding 7 — IT Premium AOV proxy (1.46) is highest; UK Premium (1.41) is close behind and underpenetrated
AOV proxy shows IT Premium at 1.46 avg purchases per user — the highest segment. UK Premium (1.41) is nearly as high but represents a smaller user base, making it an underpenetrated growth opportunity.

**Recommendation:** UK is the highest-opportunity expansion market. A targeted Premium acquisition campaign in the UK could increase overall platform AOV without requiring large user base growth.

---

### Finding 8 — Q3 is consistently the peak sales quarter; Q4 shows steepest decline
Sales spike in **July–August (Q3)** every year across all markets and categories. Q4 shows the steepest decline, particularly in Dresses and Activewear.

**Recommendation:** Align marketing spend and inventory restocking with the Q2–Q3 seasonal window. Introduce a Q4 re-activation campaign (October–November) targeting dormant users to reduce seasonal revenue dip.

---

## 🚀 Next Steps

1. **A/B test retention copy** for dormant Premium users — measure open rate, click rate, and reactivation rate
2. **Expand cohort analysis** to track 12-month retention curves by acquisition channel and country
3.  **Add real AOV and GMV tracking** once price data is available — replace proxies with exact revenue calculations
4. **Build churn prediction model** in Python using purchase frequency and recency as input features

---

## Dataset
The dataset used for this project is publicly available here:  
[📁 E-commerce Dataset](https://drive.google.com/file/d/1WPuOj8mkGCfyS1jG9ve4QqdIqcEHrDFK/view?usp=sharing)

**Dataset features include:**
- `purchase_date`: Date of the sale
- `user_uuid`: User identifier
- `category`: Product category
- `designer_id`: Designer identifier
- `language`: User language
- `level`: Price range
- `country`: User nationality
- `subscription_date`: User subscription date
- `platform`: Platform used for purchase
- `item_id`: Product ID
- `stars`: Product rating (1–5)

---

## Repository Structure

| File | Description |
|---|---|
| `sql_query.sql` | Table creation, views, RFM clustering, YoY growth, cohort retention, churn flagging |
| `Commercial_Analytics_Ecommerce.ipynb` | Python: data cleaning, EDA, segmentation, commercial metrics (AOV, GMV, LTV, churn, retention, sell-through) |
| `IMAGES` | Tableau dashboards (full period overview and 2021 annual deep dive), AOV, GMV, LTV, Churn Risk,Sell-Through, Retention Cohort |
| `Commercial_Analytics_Ecommerce.pdf` | Project summary, key insights, and strategy proposals |
| `README.md` | Case study: problem, methodology, findings, recommendations |
