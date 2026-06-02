-- ============================================================
-- Bank Customer Churn Analysis — SQL Queries
-- Dataset: Churn_Modelling (10,000 rows)
-- Target: Exited (1 = churned, 0 = retained)
-- ============================================================

-- ─────────────────────────────────────────────
-- 1. Overall Churn Rate
-- ─────────────────────────────────────────────
SELECT
    COUNT(*)                                        AS total_customers,
    SUM(Exited)                                     AS churned_customers,
    COUNT(*) - SUM(Exited)                          AS retained_customers,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM Churn_Modelling;


-- ─────────────────────────────────────────────
-- 2. Churn Rate by Geography
-- ─────────────────────────────────────────────
SELECT
    Geography,
    COUNT(*)                                        AS total_customers,
    SUM(Exited)                                     AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM Churn_Modelling
GROUP BY Geography
ORDER BY churn_rate_pct DESC;


-- ─────────────────────────────────────────────
-- 3. Churn Rate by Gender
-- ─────────────────────────────────────────────
SELECT
    Gender,
    COUNT(*)                                        AS total_customers,
    SUM(Exited)                                     AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM Churn_Modelling
GROUP BY Gender
ORDER BY churn_rate_pct DESC;


-- ─────────────────────────────────────────────
-- 4. Churn Rate by Geography AND Gender (cross-cut)
-- ─────────────────────────────────────────────
SELECT
    Geography,
    Gender,
    COUNT(*)                                        AS total_customers,
    SUM(Exited)                                     AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM Churn_Modelling
GROUP BY Geography, Gender
ORDER BY Geography, churn_rate_pct DESC;


-- ─────────────────────────────────────────────
-- 5. Average Balance and Credit Score — Churned vs Retained
-- ─────────────────────────────────────────────
SELECT
    CASE WHEN Exited = 1 THEN 'Churned' ELSE 'Retained' END AS customer_status,
    COUNT(*)                                                  AS customer_count,
    ROUND(AVG(Balance), 2)                                    AS avg_balance,
    ROUND(AVG(CreditScore), 2)                                AS avg_credit_score,
    ROUND(AVG(Age), 1)                                        AS avg_age,
    ROUND(AVG(Tenure), 1)                                     AS avg_tenure_years,
    ROUND(AVG(NumOfProducts), 2)                              AS avg_products,
    ROUND(AVG(EstimatedSalary), 2)                            AS avg_salary
FROM Churn_Modelling
GROUP BY Exited
ORDER BY Exited DESC;


-- ─────────────────────────────────────────────
-- 6. Churn by Number of Products Held
-- ─────────────────────────────────────────────
SELECT
    NumOfProducts,
    COUNT(*)                                        AS total_customers,
    SUM(Exited)                                     AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM Churn_Modelling
GROUP BY NumOfProducts
ORDER BY NumOfProducts;


-- ─────────────────────────────────────────────
-- 7. Churn by Active Membership Status
-- ─────────────────────────────────────────────
SELECT
    CASE WHEN IsActiveMember = 1 THEN 'Active' ELSE 'Inactive' END  AS membership_status,
    COUNT(*)                                                           AS total_customers,
    SUM(Exited)                                                        AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 2)                          AS churn_rate_pct
FROM Churn_Modelling
GROUP BY IsActiveMember
ORDER BY IsActiveMember;


-- ─────────────────────────────────────────────
-- 8. Top 100 Highest-Risk Customers by Predicted Probability
--    (Risk score is a heuristic proxy; replace PredictedChurnProb
--     with your model output column after scoring.)
--
--    Heuristic risk factors used here:
--      • Inactive member (+30 pts)
--      • Age 50–70 (+20 pts)
--      • Single product (+15 pts)
--      • Germany geography (+15 pts)
--      • Female gender (+10 pts)
--      • Balance > 0 (+10 pts)
-- ─────────────────────────────────────────────
SELECT TOP 100
    CustomerId,
    Surname,
    Geography,
    Gender,
    Age,
    CreditScore,
    Balance,
    NumOfProducts,
    IsActiveMember,
    Exited,
    -- Composite heuristic risk score (0–100 scale)
    (
        CASE WHEN IsActiveMember = 0     THEN 30 ELSE 0 END +
        CASE WHEN Age BETWEEN 50 AND 70  THEN 20 ELSE 0 END +
        CASE WHEN NumOfProducts = 1      THEN 15 ELSE 0 END +
        CASE WHEN Geography = 'Germany'  THEN 15 ELSE 0 END +
        CASE WHEN Gender = 'Female'      THEN 10 ELSE 0 END +
        CASE WHEN Balance > 0            THEN 10 ELSE 0 END
    )                                               AS risk_score
FROM Churn_Modelling
ORDER BY risk_score DESC, Balance DESC;


-- ─────────────────────────────────────────────
-- 9. Revenue at Risk Calculation
--    Assumes 1.5 % annual net interest margin on Balance
--    and 0.5 % fee income on EstimatedSalary as a proxy for AUM.
-- ─────────────────────────────────────────────
SELECT
    Geography,
    COUNT(*)                                                    AS at_risk_customers,
    ROUND(SUM(Balance), 2)                                      AS total_balance_at_risk,
    ROUND(SUM(EstimatedSalary), 2)                              AS total_salary_proxy_at_risk,
    -- Annual revenue at risk from balance (NIM proxy)
    ROUND(SUM(Balance) * 0.015, 2)                             AS annual_nim_revenue_at_risk,
    -- Annual fee revenue at risk (salary proxy)
    ROUND(SUM(EstimatedSalary) * 0.005, 2)                     AS annual_fee_revenue_at_risk,
    -- Combined revenue at risk
    ROUND(SUM(Balance) * 0.015 + SUM(EstimatedSalary) * 0.005, 2) AS total_annual_revenue_at_risk
FROM Churn_Modelling
WHERE Exited = 1
GROUP BY Geography
ORDER BY total_annual_revenue_at_risk DESC;


-- ─────────────────────────────────────────────
-- 10. Bonus — Churn by Age Band
-- ─────────────────────────────────────────────
SELECT
    CASE
        WHEN Age < 30              THEN '18–29'
        WHEN Age BETWEEN 30 AND 39 THEN '30–39'
        WHEN Age BETWEEN 40 AND 49 THEN '40–49'
        WHEN Age BETWEEN 50 AND 59 THEN '50–59'
        ELSE '60+'
    END                                             AS age_band,
    COUNT(*)                                        AS total_customers,
    SUM(Exited)                                     AS churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM Churn_Modelling
GROUP BY
    CASE
        WHEN Age < 30              THEN '18–29'
        WHEN Age BETWEEN 30 AND 39 THEN '30–39'
        WHEN Age BETWEEN 40 AND 49 THEN '40–49'
        WHEN Age BETWEEN 50 AND 59 THEN '50–59'
        ELSE '60+'
    END
ORDER BY MIN(Age);
