# Bank Customer Churn Prediction & Retention Strategy

## Project Overview
Customer churn is one of the most costly problems in banking. Acquiring a new customer costs 5x more than retaining an existing one. This project builds a predictive model to identify which customers are most likely to churn — and quantifies the revenue at stake — so retention teams can act before it is too late.

## Business Problem
A retail bank needed to answer: **which customers are at risk of leaving, and what is the revenue impact if they do?** This model identifies high-risk customers, ranks them by risk tier, and projects the financial impact of a targeted retention strategy.

## Dataset
- 10,000+ bank customer records
- Features include credit score, account balance, tenure, number of products, geography, age, and activity status
- Binary target: `Churn = 1` (customer left within 6 months)

## Methodology

### Step 1 — Data Preparation (SQL)
- Queried and cleaned raw customer data using SQL
- Handled missing values, encoded categorical variables, and created derived features

### Step 2 — Exploratory Data Analysis (Python)
- Identified churn rate by segment, geography, and product usage
- Visualized distribution of key features across churned vs. retained customers

### Step 3 — Model Building (Python / Scikit-learn)
- Logistic Regression classifier trained on 80/20 train-test split
- Achieved **82% prediction accuracy** on holdout test set
- Generated churn probability scores for each customer

### Step 4 — Dashboard (Power BI)
- Customer segmentation by churn risk tier (High / Medium / Low)
- Customer Lifetime Value (CLV) breakdown by segment
- Retention strategy ROI projections

## Key Findings
Top 3 churn drivers identified:
1. **Credit Score** — customers with scores below 600 showed 3x higher churn rate
2. **Account Balance** — zero-balance accounts churned at 2.5x the average rate
3. **Number of Products** — single-product customers had highest churn probability

## Business Impact
- **82% prediction accuracy** on 10,000+ customer records
- Retention strategy targeting top 15% high-risk segment projected to:
  - Reduce overall churn by **18%**
  - Preserve an estimated **$1.2M in annual revenue**

## Tools & Technologies
- **SQL** — data preparation and querying
- **Python** — EDA, logistic regression (Pandas, Scikit-learn, Matplotlib, Seaborn)
- **Power BI** — executive risk dashboard with CLV metrics

## Files
```
bank-customer-churn-prediction/
├── data/               # Dataset (source: Kaggle Bank Customer Churn)
├── sql/                # SQL queries for data preparation
├── notebooks/          # Python EDA and model building
├── dashboard/          # Power BI .pbix file
└── README.md
```

## How to Run
1. Clone the repository
2. Run SQL scripts in `/sql` to prepare the data
3. Open Jupyter notebook in `/notebooks` for EDA and model
4. Open `/dashboard/churn_dashboard.pbix` in Power BI Desktop

## Dataset Source
[Kaggle: Bank Customer Churn Dataset](https://www.kaggle.com/datasets/shubhammeshram579/bank-customer-churn-prediction)
