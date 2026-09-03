# 🎯 Customer Retention & LTV Intelligence

An end-to-end analytics project combining Python, SQL, and Power BI to identify customer churn risk, quantify lifetime value, and track monthly retention across a two-year e-commerce dataset.

## 🛠️ Tech Stack
- **Data Cleaning & Segmentation:** Python (Pandas, NumPy)
- **Database & Analytics:** SQLite (CTEs, Window Logic, Aggregations)
- **Visualization:** Power BI (DAX, connected live via the SQLite ODBC Driver)
- **Environment:** JupyterLab

---

## 🔄 Pipeline Workflow

### 1. Data Ingestion
Downloaded the UCI Online Retail II dataset (Dec 2009 – Dec 2011) — a two-year span chosen specifically to support multi-month cohort tracking, which a single-year dataset cannot provide.

### 2. Data Cleaning & Churn Risk Scoring (Python)
- Removed cancelled invoices, invalid quantities/prices, and rows missing a Customer ID.
- Calculated Recency, Frequency, and Monetary (RFM) value per customer.
- Classified each customer into a churn risk segment using a Monetary-aware, threshold-based rule (rather than relative quartile scoring), so the label stays directly interpretable for a retention use case:
  - **High Value at Risk** — inactive 180+ days AND $2,000+ lifetime spend
  - **High Risk** — inactive 180+ days (below the spend threshold)
  - **Medium Risk** — inactive 90–180 days
  - **Low Risk / Active** — purchased within the last 90 days

### 3. SQL Analytics
- Exported cleaned transactions and RFM/churn scores into SQLite.
- Built a **Cohort Retention Matrix**: tracks what percentage of each monthly cohort is still active in months 0, 1, 2, 3, 6, and 12 after their first purchase.
- Calculated **Customer Lifetime Value (CLV)** and average purchase behavior per churn risk segment.
- Queries were executed and validated directly inside the notebook before being saved to a standalone `.sql` file, ensuring the file matches exactly what was verified.

### 4. Power BI Dashboard
Connected live to the SQLite database via the SQLite3 ODBC Driver, featuring:
- KPI cards: Total Revenue, Total Customers, Average Order Value, Average CLV
- Revenue by churn risk segment
- Quarterly revenue trend
- Full cohort retention matrix (% of each cohort retained by month)

---

## 📈 Key Insights

**Overall metrics:** $8.83M total revenue across 4,312 customers, with an average order value of $459.69 and average CLV of $2.05K.

### 🎯 High-Value Churn Risk Segment
Moving beyond a standard Recency/Frequency-only churn rule surfaced a small but critical sub-segment: **High Value at Risk**.

- **Target audience:** 29 unique customers (~0.67% of the total customer base)
- **Revenue at risk:** $192,374.25 of historical revenue
- **Why it matters:** despite being a tiny fraction of the customer base, this segment's average lifetime value (~$6,633.59) is dramatically higher than the overall average CLV ($2.05K) — losing them permanently has an outsized impact on long-term revenue, far beyond what their headcount suggests.
- **Retention implication:** rather than spreading a retention budget evenly across the full "High Risk" cohort (796 customers), this segmentation lets retention efforts prioritize these 29 high-value accounts specifically, with personalized outreach and loyalty incentives.

### 📊 Cohort Retention
The retention matrix shows a consistent drop-off pattern across cohorts, with a notable share of each monthly cohort still active at the 6- and 12-month marks — a baseline that can be tracked over time to measure whether retention initiatives are working.

**Data limitation:** later cohorts (e.g. customers acquired from mid-2010 onward) show zero or missing values at longer month indices (6, 12) simply because the dataset ends in December 2011 — those customers have not yet had the chance to reach that milestone within the observation window. This is a right-censoring effect inherent to any fixed-period dataset, not a data quality issue.

## 📁 Files
- `01_Customer_Retention_Data_Cleaning.ipynb` — data ingestion, cleaning, RFM/churn scoring, and SQL export (queries executed and validated in-notebook).
- `02_SQL_Cohort_Retention_Analysis.sql` — standalone cohort retention and CLV query file.
- Power BI dashboard export (see repository).

## 📊 Data Source
UCI Machine Learning Repository — Online Retail II dataset (raw data not included in this repository due to size; downloaded automatically by the cleaning notebook).
