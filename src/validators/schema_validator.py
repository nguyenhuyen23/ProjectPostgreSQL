from pathlib import Path
import pandas as pd

dirty_path = Path(__file__).resolve().parents[2] / "data/dirty/day_2026-07-02"
print(dirty_path)

REQUIRED = {
    'customers':['customer_id','full_name','email','status'],
    'products':['product_id','category_id','product_name','unit_price','status'],
    'orders':['order_id','customer_id','order_date','status','order_total'],
    'order_items':['order_item_id','order_id','product_id','quantity','unit_price','discount_amount'],
    'payments':['payment_id','order_id','payment_date','payment_status','amount'],
}

customers = pd.read_csv(dirty_path / "customers_daily.csv")
products = pd.read_csv(dirty_path / "products_daily.csv")
orders = pd.read_csv(dirty_path / "orders_daily.csv")
order_items = pd.read_csv(dirty_path / "order_items_daily.csv")
payments = pd.read_json(dirty_path / "payments_daily.json")


def validate_schema(name, df):
    log_list = []
    missing_col = [c for c in REQUIRED[name] if c not in df.columns]
    if missing_col:
        raise ValueError(
            f"{name}: missing columns {missing_col}" )
    df_records = df.copy()
    df_records[f"score"] = 100 - (df[REQUIRED[name]].isnull().sum(axis=1)/len(REQUIRED[name])) * 100
    df_records["errors"] = ""
    df_records.loc[df_records[f"score"] != 100, "errors"] = ("[MISSING_REQUIRED]" )
    
    error_rows = df_records.query('errors == "[MISSING_REQUIRED]"')
    key_col = REQUIRED[name][0]
    for _, row in error_rows.iterrows():
        log_list.append(
            [f"table: {name}\n",
            f"row_id={row[key_col]}, "
            f"score={row['score']:.0f}, "
            f"error={row['errors']}"]
        )
    return log_list       

    