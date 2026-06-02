# Power BI Dashboard Guide — Bank Customer Churn

## Overview
This guide walks you through building a five-visual executive churn dashboard in Power BI Desktop using **Churn_Modelling.csv**. Follow the steps in order; each section maps to one visual on the canvas.

---

## Step 1 — Import the CSV

1. Open **Power BI Desktop** → **Home** ribbon → **Get Data** → **Text/CSV**.
2. Browse to `Churn_Modelling.csv` and click **Open**.
3. In the preview dialog verify the delimiter is **Comma** and the first row is the header row.
4. Click **Load** (not *Transform* — the data is ready to use as-is).
5. In the **Fields** pane on the right you should now see the table **Churn_Modelling** with all 14 columns.

### Optional: rename the table
Right-click **Churn_Modelling** in the Fields pane → **Rename** → type `Customers`.

---

## Step 2 — Create the Three DAX Measures

Go to **Home → New measure** (or right-click the table → **New measure**) and paste each formula below.

### Measure 1 — Churn Rate
```dax
Churn Rate =
DIVIDE(
    CALCULATE(COUNTROWS(Customers), Customers[Exited] = 1),
    COUNTROWS(Customers),
    0
)
```
*Format as **Percentage** with 1 decimal place.*

---

### Measure 2 — Average Customer Lifetime Value (CLV)
```dax
Average CLV =
AVERAGEX(
    Customers,
    Customers[Balance] * 0.015 + Customers[EstimatedSalary] * 0.005
)
```
*This applies a 1.5 % net interest margin on balances and 0.5 % fee rate on salary as CLV proxies.*
*Format as **Currency** ($ or € depending on your locale).*

---

### Measure 3 — Revenue at Risk
```dax
Revenue at Risk =
CALCULATE(
    SUMX(
        Customers,
        Customers[Balance] * 0.015 + Customers[EstimatedSalary] * 0.005
    ),
    Customers[Exited] = 1
)
```
*Format as **Currency**.*

---

## Step 3 — Build the Five Visuals

Resize your canvas to **16:9** via **View → Page view → Fit to page** before placing visuals.

---

### Visual 1 — KPI Cards (top row)

**Visual type:** Card (×3, arranged in a row)

| Card | Field to drag in |
|------|-----------------|
| Total Customers | `Customers[CustomerId]` → Count (Distinct) |
| Churn Rate | `[Churn Rate]` measure |
| Revenue at Risk | `[Revenue at Risk]` measure |

**Steps:**
1. Click **Card** in the Visualizations pane.
2. Drag **CustomerId** into *Fields* → change aggregation to **Count (Distinct)**.
3. Repeat for the two measures.
4. Arrange the three cards in a row across the top of the canvas.

**Executive insight:** Gives leadership an instant read on portfolio health and the financial cost of churn before they look at any chart.

---

### Visual 2 — Churn Rate by Geography (Clustered Bar Chart)

**Visual type:** Clustered bar chart

| Well | Field |
|------|-------|
| Y-axis | `Customers[Geography]` |
| X-axis | `[Churn Rate]` |
| Tooltips | `[Revenue at Risk]`, Count of CustomerId |

**Steps:**
1. Select **Clustered bar chart**.
2. Drag `Geography` → **Y-axis**.
3. Drag `[Churn Rate]` → **X-axis**.
4. In **Format visual → Data labels**, turn on labels and set format to *Percentage, 1 decimal*.
5. Sort bars descending by Churn Rate (click the sort icon on the visual header).

**Executive insight:** Germany consistently shows ~32 % churn vs ~16 % in France and Spain. Geographic segmentation is the single clearest driver for targeted retention campaigns.

---

### Visual 3 — Churn Rate by Age Group (Column Chart)

**Visual type:** Clustered column chart

First, create an **Age Band** calculated column:
1. **Home → New column** → paste:
```dax
Age Band =
SWITCH(
    TRUE(),
    Customers[Age] < 30,           "18–29",
    Customers[Age] < 40,           "30–39",
    Customers[Age] < 50,           "40–49",
    Customers[Age] < 60,           "50–59",
    "60+"
)
```

| Well | Field |
|------|-------|
| X-axis | `Customers[Age Band]` |
| Y-axis | `[Churn Rate]` |
| Tooltips | Count of CustomerId |

**Steps:**
1. Select **Clustered column chart**.
2. Drag `Age Band` → **X-axis**; drag `[Churn Rate]` → **Y-axis**.
3. In **Format visual → X-axis**, set sort order manually: 18–29, 30–39, 40–49, 50–59, 60+.

**Executive insight:** Churn peaks in the 50–59 age band (~57 %) — likely customers approaching retirement who consolidate accounts. This group warrants a dedicated wealth-advisory retention programme.

---

### Visual 4 — Balance Distribution: Churned vs Retained (Box Plot or Violin via custom visual)

**Recommended alternative if Box Plot is unavailable:** Use a **Stacked column chart** binned by balance range.

Create a **Balance Band** calculated column:
```dax
Balance Band =
SWITCH(
    TRUE(),
    Customers[Balance] = 0,                   "No Balance",
    Customers[Balance] < 50000,               "<50K",
    Customers[Balance] < 100000,              "50K–100K",
    Customers[Balance] < 150000,              "100K–150K",
    "150K+"
)
```

| Well | Field |
|------|-------|
| X-axis | `Customers[Balance Band]` |
| Y-axis | `[Churn Rate]` |
| Legend | *(leave empty; filter by Exited for drill-through)* |

**Steps:**
1. Select **Clustered column chart**.
2. Drag `Balance Band` → **X-axis**; `[Churn Rate]` → **Y-axis**.
3. Sort X-axis manually: No Balance, <50K, 50K–100K, 100K–150K, 150K+.

**Executive insight:** Customers with **no balance** churn at a high rate (likely dormant accounts), but mid-to-high balance customers (50K–150K) who churn represent the largest revenue loss per customer. Retention ROI is highest targeting this band.

---

### Visual 5 — Active vs Inactive Member Churn Rate (Donut Chart ×2 side-by-side)

**Visual type:** Donut chart (place two side-by-side, filtered)

**Steps:**
1. Insert a **Donut chart**.
2. Drag `Customers[Exited]` → **Values** (change aggregation to **Count**).
3. Drag `Customers[IsActiveMember]` → **Legend** (this will split the donut).

**Alternative — simpler single visual:**
1. Use a **Clustered column chart**.
2. X-axis: create a calculated column:
```dax
Member Status = IF(Customers[IsActiveMember] = 1, "Active", "Inactive")
```
3. Y-axis: `[Churn Rate]`.

**Executive insight:** Inactive members churn at roughly **2× the rate** of active members. Even a basic re-engagement email series targeting inactive members could halve this segment's churn.

---

## Step 4 — Final Dashboard Polish

1. **Add slicers** (Visualizations → Slicer) for:
   - `Geography` (Dropdown style)
   - `Gender` (Tile style)
   - `NumOfProducts` (Between slider)

2. **Theme:** Home → Themes → choose **Executive** or **Accessible default** for boardroom-ready styling.

3. **Page title:** Insert → Text box → "Bank Customer Churn — Executive Overview" (font size 20, bold).

4. **Cross-filtering:** All visuals are cross-filtered by default. Click a bar in Visual 2 to automatically filter the rest of the page — no extra setup needed.

5. **Publish:** Home → Publish → select your Power BI workspace to share with stakeholders.

---

## Quick-Reference: Fields in the Dataset

| Column | Type | Description |
|--------|------|-------------|
| RowNumber | Integer | Row index (exclude from analysis) |
| CustomerId | Integer | Unique customer identifier |
| Surname | Text | Customer surname |
| CreditScore | Integer | Credit score (350–850) |
| Geography | Text | France / Germany / Spain |
| Gender | Text | Male / Female |
| Age | Integer | Customer age |
| Tenure | Integer | Years with the bank (0–10) |
| Balance | Decimal | Account balance |
| NumOfProducts | Integer | Bank products held (1–4) |
| HasCrCard | Binary | 1 = has credit card |
| IsActiveMember | Binary | 1 = active in last period |
| EstimatedSalary | Decimal | Estimated annual salary |
| Exited | Binary | **Target** — 1 = churned |
