import os
import pandas as pd
import snowflake.connector
from dotenv import load_dotenv
from snowflake.connector.pandas_tools import write_pandas

load_dotenv()

df = pd.read_csv("data/clean_sales.csv")
df.columns = [column.upper() for column in df.columns]

conn = snowflake.connector.connect(
    account=os.getenv("sf_account"),
    user=os.getenv("sf_user"),
    password=os.getenv("sf_password"),
    warehouse=os.getenv("sf_warehouse"),
    database=os.getenv("sf_database"),
    schema=os.getenv("sf_schema")
)   

success, nchunks, nrows, _ = write_pandas(
    conn=conn,
    df=df,
    table_name="SALES_RAW",
    schema=os.getenv("sf_schema")
)

print(f"Load successful: {success}")
print(f"Chunks: {nchunks}")
print(f"Rows loaded: {nrows}")

conn.close()
