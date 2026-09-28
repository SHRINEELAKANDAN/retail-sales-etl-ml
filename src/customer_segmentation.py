import os
import pandas as pd
import snowflake.connector
from dotenv import load_dotenv
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from snowflake.connector.pandas_tools import write_pandas

load_dotenv()

conn = snowflake.connector.connect(
    account=os.getenv("sf_account"),
    user=os.getenv("sf_user"),
    password=os.getenv("sf_password"),
    warehouse=os.getenv("sf_warehouse"),
    database=os.getenv("sf_database"),
    schema=os.getenv("sf_schema")
)

query = """
SELECT customer_id, total_orders, total_spend, avg_sales_line, 
        unique_products, recency_days
FROM RETAIL_DB.ANALYTICS.CUSTOMER_FEATURES
"""

df = pd.read_sql(query, conn)
df.columns = [column.lower() for column in df.columns]

features = [
    "total_orders", 
    "total_spend", 
    "avg_sales_line", 
    "unique_products", 
    "recency_days"
]

scaled_features = StandardScaler().fit_transform(df[features])

model = KMeans(n_clusters=3, random_state=42, n_init=10)

df["customer_segment"] = model.fit_predict(scaled_features)

df.columns =[column.upper() for column in df.columns]

success, nchunks, nrows,_ = write_pandas(
    conn=conn,
    df=df,
    table_name="CUSTOMER_SEGMENTATION",
    auto_create_table=True,
    overwrite=True
)

print(f"Load successful: {success}; Chunks: {nchunks}; Rows loaded: {nrows}")
conn.close()