-- ============================================================
-- Project: Enterprise Customer Retention & LTV Intelligence
-- File: 02_SQL_Cohort_Retention_Analysis.sql
-- Description: Advanced SQL Analytics using CTEs, Window Logic & Aggregations
-- ============================================================

-- 1. Cohort Retention Matrix (Monthly Retention Tracking)
WITH First_Purchase AS (
    SELECT 
        `Customer ID` AS CustomerID,
        DATE(MIN(InvoiceDate), 'start of month') AS CohortMonth
    FROM online_retail_clean
    GROUP BY `Customer ID`
),
Customer_Activity AS (
    SELECT 
        r.`Customer ID` AS CustomerID,
        DATE(r.InvoiceDate, 'start of month') AS ActivityMonth,
        fp.CohortMonth,
        (CAST(STRFTIME('%Y', r.InvoiceDate) AS INTEGER) - CAST(STRFTIME('%Y', fp.CohortMonth) AS INTEGER)) * 12 +
        (CAST(STRFTIME('%m', r.InvoiceDate) AS INTEGER) - CAST(STRFTIME('%m', fp.CohortMonth) AS INTEGER)) AS MonthIndex
    FROM online_retail_clean r
    JOIN First_Purchase fp ON r.`Customer ID` = fp.CustomerID
)
SELECT 
    CohortMonth,
    COUNT(DISTINCT CustomerID) AS Total_Cohort_Customers,
    COUNT(DISTINCT CASE WHEN MonthIndex = 0 THEN CustomerID END) AS Month_0,
    COUNT(DISTINCT CASE WHEN MonthIndex = 1 THEN CustomerID END) AS Month_1,
    COUNT(DISTINCT CASE WHEN MonthIndex = 2 THEN CustomerID END) AS Month_2,
    COUNT(DISTINCT CASE WHEN MonthIndex = 3 THEN CustomerID END) AS Month_3,
    COUNT(DISTINCT CASE WHEN MonthIndex = 6 THEN CustomerID END) AS Month_6,
    COUNT(DISTINCT CASE WHEN MonthIndex = 12 THEN CustomerID END) AS Month_12
FROM Customer_Activity
GROUP BY CohortMonth
ORDER BY CohortMonth;


-- 2. Customer Lifetime Value (CLV) & Risk Segment Metrics
WITH Customer_Value AS (
    SELECT 
        r.CustomerID,
        r.ChurnRisk,
        r.Recency,
        r.Frequency,
        r.Monetary,
        ROUND(r.Monetary / r.Frequency, 2) AS AvgOrderValue,
        CAST(JULIANDAY(MAX(t.InvoiceDate)) - JULIANDAY(MIN(t.InvoiceDate)) AS INTEGER) AS CustomerLifespanDays
    FROM customer_rfm_scores r
    JOIN online_retail_clean t ON r.CustomerID = t.`Customer ID`
    GROUP BY r.CustomerID
)
SELECT 
    ChurnRisk,
    COUNT(CustomerID) AS TotalCustomers,
    ROUND(SUM(Monetary), 2) AS SegmentTotalRevenue,
    ROUND(AVG(Monetary), 2) AS AvgLifetimeValue_CLV,
    ROUND(AVG(AvgOrderValue), 2) AS Overall_AvgOrderValue,
    ROUND(AVG(Frequency), 1) AS AvgPurchaseFrequency,
    ROUND(AVG(CustomerLifespanDays), 0) AS AvgLifespanDays
FROM Customer_Value
GROUP BY ChurnRisk
ORDER BY SegmentTotalRevenue DESC;