# Credit Card Default Risk Analytics and Financial Exposure Management

## Project Overview
Credit risk governance is the primary line of defense in consumer lending and retail banking. While granting credit limits drives interest income and merchant interchange fees, unmanaged defaults erode core operating capital and escalate Non Performing Loan ratios.

This project translates 30,000 real world customer accounts from the UCI Credit Card repository into an actionable credit risk governance framework. By connecting credit history indicators with proactive risk mitigation, this system identifies financial distress one month before severe delinquency happens, enabling automated risk management operations and safeguarding capital reserves.

---

## Dataset Overview and Data Dictionary
The project utilizes the UCI Credit Card dataset comprising 30,000 retail customer profiles with 25 attributes tracking six months of financial behavior from April to September.

| Feature Group | Column Name | Data Type | Business Meaning and Description |
| :--- | :--- | :--- | :--- |
| Demographics | LIMIT_BAL | Integer | Credit limit granted to the account holder in NTD. |
| Demographics | SEX | Categorical | Cardholder gender where 1 indicates male and 2 indicates female. |
| Demographics | EDUCATION | Categorical | Highest level achieved: 1 Graduate School, 2 University, 3 High School, 4 Others. |
| Demographics | MARRIAGE | Categorical | Marital status: 1 Married, 2 Single, 3 Others. |
| Demographics | AGE | Integer | Age of customer in complete years. |
| Repayment History | PAY_0 to PAY_6 | Categorical | Delinquency tracking from September to April: negative 1 indicates normal payment, 1 to 8 indicate delay of one to eight months. |
| Billing Statements | BILL_AMT1 to BILL_AMT6 | Integer | Outstanding statement balances recorded from September to April in NTD. |
| Actual Payments | PAY_AMT1 to PAY_AMT6 | Integer | Actual funds repaid during each corresponding billing cycle in NTD. |
| Target Variable | default.payment.next.month | Binary | Default flag next month: 1 indicates default and 0 indicates normal settlement with 22.12 percent baseline rate. |

---

## Target Business Questions
To deliver direct value to Credit Risk Management and Debt Recovery operations, this project addresses four core business questions:

* Delinquency Severity: How significantly does a prior payment delay of two or more months escalate the statistical probability of upcoming default?
* Underwriting Thresholds: Does default risk increase among lower credit limit segments, and does this justify dynamic limit adjustments?
* Financial Stress Markers: How do credit line utilization exceeding 80 percent and minimum payment patterns signal impending insolvency?
* Operational Debt Collection: How can high exposure accounts under repayment stress be automatically routed into prioritized soft collection workflows before becoming uncollectible losses?

---

## Key Business Insights and Portfolio Findings

* Delinquency Multiplier: Customers exhibiting repayment delays of two months or longer demonstrate an overwhelming default incidence of 69 to 78 percent, compared to 12.75 percent for cardholders who pay on time. This represents a 3.63 times surge in default probability.
* Underwriting Limit Dynamics: Borrowers with assigned credit limits below 50,000 NTD default at an elevated rate of 36.07 percent, whereas borrowers with limits above 200,000 NTD maintain a default rate of only 15.13 percent, validating initial underwriting scorecards.
* Credit Line Overextension: Credit cardholders who push their credit utilization beyond 80 percent while paying only the minimum balance exhibit severe financial distress and represent the vast majority of impending defaults.
* Capital Exposure: Delinquent cardholders facing financial distress represent 273 million NTD in immediate portfolio credit exposure, creating a massive opportunity for loss reduction through proactive intervention.

---

## Strategic Recommendations for Risk Operations

* Automated Early Warning Reminders: Trigger automated digital notices five to ten days before payment due dates for customers whose credit utilization surpasses 80 percent or whose payment delay enters the one month stage.
* Dynamic Credit Line Management: Restrict credit card limit increases and temporarily curtail credit lines for non delinquent customers showing three consecutive months of rising utilization coupled with dropping repayment ratios.
* Operational Soft Collection Queue: Direct collection resources toward critical delinquent accounts with substantial balances, while using cost effective automated communication channels for low exposure customers.

---

## Technical Architecture and Project Structure

```text
├── data/
│   ├── [GenZ] UCI_Credit_Card.csv    # Raw baseline dataset (30,000 profiles)
│   ├── processed_analytics.csv       # Normalized data model for business reporting
│   └── processed_model.csv           # Cleaned feature table for risk modeling
├── notebooks/
│   └── credit_risk_analytics.ipynb   # Unified EDA, feature engineering, and modeling pipeline
├── sql/
│   ├── 01_data_preparation.sql       # Staging views and data normalization
│   └── 02_feature_engineering.sql    # Relational feature extraction via CTEs
├── dashboard/
│   └── credit_risk_dashboard.pbix    # Three page executive analytics dashboard
├── images/
│   ├── executive_overview.png        # Portfolio KPI distribution
│   ├── early_warning.png             # Delinquency and debt collection prioritization
│   └── behavior_profiling.png        # Cross sectional demographic behavior
├── requirements.txt
├── .gitignore
└── README.md
```
### 1. Data Normalization and Relational Modeling
Cleaned anomalous categories in education and marital status using structured SQL logic. Extracted bill balance variances and historical repayment trends using Common Table Expressions and Window Functions.

### 2. Financial Feature Engineering
Formulated critical credit indicators including Credit Utilization Ratio, Payment to Bill Ratio, Maximum Historical Delinquency, and Severe Delinquency flags to categorize cardholders into High, Medium, and Low risk tiers.

### 3. Executive Intelligence Architecture
Designed a three page reporting system in Power BI built upon an optimized Star Schema:

* **Executive Overview:** High level portfolio health, default rates, and exposure distribution by limit tiers.
* **Behavioral Profiling:** Cross examination of default patterns across demographic groups and utilization brackets.
* **Early Warning Matrix:** Operational debt collection queue prioritized by outstanding balance and risk severity.

### 4. Machine Learning Benchmarking
Trained and evaluated predictive algorithms to optimize ROC AUC and Recall on default accounts:

* **Logistic Regression:** 0.7240 ROC AUC as linear baseline comparison.
* **Random Forest:** 0.7685 ROC AUC as ensemble benchmark.
* **XGBoost Classifier:** 0.7815 ROC AUC as champion model with optimized class balancing.

---

## Getting Started

### Prerequisites
* Python 3.9 or higher
* Jupyter Notebook or Visual Studio Code
* Microsoft Power BI Desktop for opening reporting dashboards

### Setup and Execution

1. Clone repository:
```bash
git clone [https://github.com/anhduonghong/credit-risk-analysis-.git](https://github.com/anhduonghong/credit-risk-analysis-.git)
cd credit-risk-analysis-
```
2.Database Setup and SQL Execution

1. Load `data/[GenZ] UCI_Credit_Card.csv` into your relational database (PostgreSQL, MySQL, or SQL Server).
2. Execute `sql/01_data_preparation.sql` to clean invalid categories and standardize baseline demographics.
3. Execute `sql/02_feature_engineering.sql` to compute monthly balance shifts and credit risk tiers via CTEs and Window Functions.
