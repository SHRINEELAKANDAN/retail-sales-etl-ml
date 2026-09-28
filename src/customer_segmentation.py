import os
import pandas as pd
from dotenv import load_dotenv
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sqlalchemy import create_engine, text
from snowflake.sqlalchemy import URL

load_dotenv()

engine = create_engine(
    URL(
        account=os.getenv("sf_account"),
        user=os.getenv("sf_user"),
        password=os.getenv("sf_password"),
        warehouse=os.getenv("sf_warehouse"),
        database=os.getenv("sf_database"),
        schema="ANALYTICS"
    )
)

query = """
SELECT 
    customer_id, 
    total_orders, 
    total_spend,
    avg_sales_line, 
    unique_products,
    recency_days
FROM RETAIL_DB.ANALYTICS.CUSTOMER_FEATURES
"""

try:
    with engine.connect() as sqlalchemy_conn:
        df = pd.read_sql_query(text(query), sqlalchemy_conn)

    df.columns = df.columns.str.lower()

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

    df.columns =df.columns.str.upper()

    df.to_sql(
        "CUSTOMER_SEGMENTATION", 
        con=engine, 
        schema=os.getenv("ANALYTICS"), 
        if_exists="replace", 
        index=False,
        method="multi"
    )

    print("Customer segmentation completed and results loaded to Snowflake.")

finally:
    engine.dispose()