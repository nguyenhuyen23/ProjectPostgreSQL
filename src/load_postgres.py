import json
from datetime import datetime, timezone
from .config import SETTINGS
from sqlalchemy import text
from .database import engine
from .api_client import fetch_all_pages, save_raw_rows
from src.transform import normalize
import pandas as pd

PK = {
    'customers':'customer_id', 'products':'product_id', 'orders':'order_id',
    'order_items':'order_item_id', 'payments':'payment_id'
}


def upsert_dataframe(name, df):
    """TODO Buổi 6: INSERT ... ON CONFLICT ... DO UPDATE. Trả inserted/updated stats."""
    print(f"Đang upsert bảng: {name}")
    if df.empty:
        return {
                "inserted_or_updated": 0
                }
    pk = PK[name]
    cols = [c for c in df.columns if c not in ["error_code"]]
    placeholders = ", ".join(":" + c for c in cols)
    updates = ", ".join(f"{c}=EXCLUDED.{c}"for c in cols if c != pk)
    sql = text(f"""INSERT INTO core.{name}({",".join(cols)})VALUES ({placeholders}) ON CONFLICT ({pk}) DO UPDATE SET {updates}""")
    records = []
    for row in (df[cols].to_dict("records")):
        records.append({k: ( 
                None 
                if str(v) == "NaT" 
                else (v.to_pydatetime()
                if hasattr(
                    v,
                    "to_pydatetime")
                else v
            )
            )
            for k, v in row.items()
            })
    with engine.begin() as conn:
        conn.execute(sql,records)
        result = conn.execute(text(f"SELECT COUNT(*) FROM core.{name}"))

        total_records = result.scalar_one()

        print(f"Tổng số bản ghi trong bảng {name}: {total_records}")
    return {"inserted_or_updated":len(records),
            "total_records": total_records}


