# Retail Sales ETL and Customer Segmentation

An end-to-end data engineering and machine learning project built with Python, Snowflake SQL, SQLAlchemy, scikit-learn, and Git.

The project cleans online retail transaction data, loads it into Snowflake, builds analytics tables, creates customer-level ML features, and applies K-Means clustering to segment customers.

## Architecture

```text
Online Retail Excel Dataset
            |
            v
Python Data Cleaning and Validation
            |
            v
Snowflake RAW.SALES_RAW
            |
            v
Snowflake ANALYTICS.FACT_SALES
            |
            v
Snowflake ANALYTICS.CUSTOMER_FEATURES
            |
            v
Python Feature Scaling and K-Means Clustering
            |
            v
Snowflake ANALYTICS.CUSTOMER_SEGMENTATION
            |
            v
SQL Business Analytics Queries
```

## Technologies Used

- Python
- pandas
- scikit-learn
- Snowflake
- Snowflake SQL
- SQLAlchemy
- Snowflake SQLAlchemy
- python-dotenv
- Git and GitHub

## Dataset

This project uses the UCI Online Retail dataset.

- Dataset source: https://archive.ics.uci.edu/dataset/352/online+retail
- File name: `Online Retail.xlsx`
- Download location in project:

```text
data/raw/Online Retail.xlsx
```

The dataset contains transactional sales records from a UK-based online retailer.

## Project Structure

```text
retail-sales-etl-ml/
├── data/
│   └── raw/
│       └── Online Retail.xlsx
├── sql/
│   ├── setup.sql
│   ├── transform.sql
│   └── analytics.sql
├── src/
│   ├── clean_data.py
│   ├── load_to_snowflake.py
│   ├── test_connection.py
│   └── customer_segmentation.py
├── requirements.txt
├── .gitignore
└── README.md
```

## Setup

### 1. Clone the repository

```bash
git clone [https://github.com/SHRINEELAKANDAN/retail-sales-etl-ml.git]
(https://github.com/SHRINEELAKANDAN/retail-sales-etl-ml.git)
cd retail-sales-etl-ml
```

### 2. Create a virtual environment

For Windows PowerShell:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### 3. Install dependencies

```powershell
pip install -r requirements.txt
```

Use this `requirements.txt`:

```text
pandas
openpyxl
scikit-learn
python-dotenv
snowflake-connector-python[pandas]
snowflake-sqlalchemy>=1.9.0
SQLAlchemy>=2.0,<2.1
```

## Environment Configuration

Create a `.env` file in the root folder.

### Username and password authentication

```text
sf_account=your_account_identifier
sf_user=your_snowflake_username
sf_password=your_snowflake_password
sf_warehouse=RETAIL_WH
sf_database=RETAIL_DB
sf_schema=RAW
```

Add these entries to `.gitignore`:

```text
.env
.venv/
__pycache__/
*.pyc
data/clean_sales.csv
```

Do not upload `.env` because it can contain sensitive account and authentication details.

## Pipeline Execution

### Step 1: Clean source data

Run:

```powershell
python src\clean_data.py
```

This script:

- Reads `data/raw/Online Retail.xlsx`
- Removes duplicate records
- Removes rows with missing customer IDs or missing product descriptions
- Removes invalid quantities and unit prices
- Converts columns to suitable data types
- Creates a `sales_amount` field

```text
sales_amount = quantity * unit_price
```

- Writes cleaned data to:

```text
data/clean_sales.csv
```

### Step 2: Create Snowflake objects

Run `sql/setup.sql` in Snowflake Snowsight.

The SQL file creates:

```text
RETAIL_WH
RETAIL_DB
RETAIL_DB.RAW
RETAIL_DB.ANALYTICS
RETAIL_DB.RAW.SALES_RAW
```

### Step 3: Test the Snowflake connection

Run:

```powershell
python src\test_connection.py
```

Run:

```powershell
python src\load_to_snowflake.py
```

This script loads the cleaned dataset into:

```text
RETAIL_DB.RAW.SALES_RAW
```

### Step 5: Transform the sales data

Run `sql/transform.sql` in Snowflake Snowsight.

This creates:

```text
RETAIL_DB.ANALYTICS.FACT_SALES
RETAIL_DB.ANALYTICS.CUSTOMER_FEATURES
```

`FACT_SALES` stores cleaned transaction-level data.

`CUSTOMER_FEATURES` stores one row per customer and includes:

- `total_orders`
- `total_spend`
- `avg_sales_line`
- `unique_products`
- `recency_days`

### Step 6: Run ML customer segmentation

Run:

```powershell
python src\customer_segmentation.py
```

The script:

1. Reads customer features from Snowflake.
2. Selects numeric customer-behavior features.
3. Applies `StandardScaler` to prevent high-value columns such as total spend from dominating the clustering process.
4. Uses K-Means clustering with three clusters.
5. Adds a `customer_segment` column to each customer.
6. Loads results into:

```text
RETAIL_DB.ANALYTICS.CUSTOMER_SEGMENTATION
```

## Analytics Queries

Run the queries in `sql/analytics.sql`.

### Monthly revenue trend

```sql
SELECT
    DATE_TRUNC('MONTH', invoice_date) AS sales_month,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders,
    COUNT(DISTINCT customer_id) AS active_customers
FROM RETAIL_DB.ANALYTICS.FACT_SALES
GROUP BY sales_month
ORDER BY sales_month;
```

### Top 10 products by revenue

```sql
SELECT
    stock_code,
    description,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    SUM(quantity) AS total_quantity_sold,
    COUNT(DISTINCT invoice_no) AS total_orders
FROM RETAIL_DB.ANALYTICS.FACT_SALES
WHERE description IS NOT NULL
GROUP BY
    stock_code,
    description
ORDER BY total_revenue DESC
LIMIT 10;
```

### Revenue by country

```sql
SELECT
    country,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM RETAIL_DB.ANALYTICS.FACT_SALES
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_revenue DESC;
```

### Customer-segment distribution

```sql
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage
FROM RETAIL_DB.ANALYTICS.CUSTOMER_SEGMENTATION
GROUP BY customer_segment
ORDER BY customer_segment;
```

### Customer-segment profile

```sql
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_total_spend,
    ROUND(AVG(total_orders), 2) AS avg_total_orders,
    ROUND(AVG(avg_sales_line), 2) AS avg_line_value,
    ROUND(AVG(unique_products), 2) AS avg_unique_products,
    ROUND(AVG(recency_days), 2) AS avg_recency_days
FROM RETAIL_DB.ANALYTICS.CUSTOMER_SEGMENTATION
GROUP BY customer_segment
ORDER BY avg_total_spend DESC;
```

### Data-quality row count check

```sql
SELECT
    'RAW_SALES' AS table_name,
    COUNT(*) AS row_count
FROM RETAIL_DB.RAW.SALES_RAW

UNION ALL

SELECT
    'FACT_SALES' AS table_name,
    COUNT(*) AS row_count
FROM RETAIL_DB.ANALYTICS.FACT_SALES;
```

### Raw-data quality checks

```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT_IF(customer_id IS NULL) AS missing_customer_id,
    COUNT_IF(quantity <= 0) AS invalid_quantity,
    COUNT_IF(unit_price <= 0) AS invalid_unit_price,
    COUNT_IF(sales_amount <= 0) AS invalid_sales_amount
FROM RETAIL_DB.RAW.SALES_RAW;
```

## Customer Segment Interpretation

K-Means creates technical cluster identifiers such as `0`, `1`, and `2`. These numbers do not automatically represent a business category.

Use the cluster-profile query to inspect each group before assigning a label.

| Customer Behavior | Business Label |
|---|---|
| High spending, many orders, low recency days | High-value active customers |
| Moderate spending and moderate order frequency | Occasional customers |
| Low spending, few orders, high recency days | Inactive or at-risk customers |
| High spending but high recency days | Previously high-value, now inactive |

Lower `recency_days` means the customer purchased more recently.

## Validation Queries

```sql
SELECT COUNT(*) AS raw_sales_rows
FROM RETAIL_DB.RAW.SALES_RAW;
```

```sql
SELECT COUNT(*) AS fact_sales_rows
FROM RETAIL_DB.ANALYTICS.FACT_SALES;
```

```sql
SELECT COUNT(*) AS customer_feature_rows
FROM RETAIL_DB.ANALYTICS.CUSTOMER_FEATURES;
```

```sql
SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM RETAIL_DB.ANALYTICS.CUSTOMER_SEGMENTATION
GROUP BY customer_segment
ORDER BY customer_segment;
```

## Key Skills Demonstrated

- Python ETL development
- Data validation and cleaning with pandas
- Snowflake warehouse, database, schema, and table creation
- SQL transformation and aggregation
- Raw and analytics data-layer design
- Customer feature engineering
- Feature scaling using `StandardScaler`
- K-Means customer segmentation
- SQLAlchemy-based Snowflake connectivity
- Data-quality validation queries
- Git-based version control

## Future Improvements

- Add Snowpipe for automatic file ingestion.
- Use Snowflake Streams and Tasks for incremental transformations.
- Add audit logs for source files and pipeline runs.
- Add rejected-record tables for data-quality failures.
- Use elbow method and silhouette score to evaluate optimal cluster count.
- Build a dashboard with Streamlit, Power BI, or Tableau.
- Create `DIM_CUSTOMER`, `DIM_PRODUCT`, and `DIM_DATE` dimension tables.
- Add automated testing and GitHub Actions.
