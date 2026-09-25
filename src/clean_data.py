import pandas as pd

input_file = "data/raw/Online_Retail.xlsx"
output_file = "data/clean_sales.csv"

df = pd.read_excel(input_file)

df.columns = [
    "invoice_no", 
    "stock_code",
    "description",
    "quantity",
    "invoice_date",
    "unit_price",
    "customer_id",
    "country"
]

df = df.dropna(subset=["customer_id", "description"])
df = df.drop_duplicates()

df["quantity"] = pd.to_numeric(df["quantity"], errors="coerce")
df["unit_price"] = pd.to_numeric(df["unit_price"], errors="coerce")

df = df[(df["quantity"] > 0) & (df["unit_price"] > 0)]

df["invoice_date"] = pd.to_datetime(df["invoice_date"])

df["sales_amount"] = df["quantity"] * df["unit_price"]

df.to_csv(output_file, index=False)

print(f"Clean rows: {len(df)}")
print(df.head())