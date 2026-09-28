import os
import snowflake.connector
from dotenv import load_dotenv

load_dotenv()

conn =snowflake.connector.connect(
    account=os.getenv("sf_account"),
    user=os.getenv("sf_user"),
    password=os.getenv("sf_password"),
    warehouse=os.getenv("sf_warehouse"),
    database=os.getenv("sf_database"),
    schema=os.getenv("sf_schema")
)

cursor = conn.cursor()
cursor.execute("SELECT CURRENT_USER(), CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_WAREHOUSE()")

print(cursor.fetchone())

cursor.close()
conn.close()
