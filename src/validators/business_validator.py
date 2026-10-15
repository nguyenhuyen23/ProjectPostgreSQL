import re
import pandas as pd
from pathlib import Path

EMAIL = re.compile(
    r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


VALID = {

    "customers": {
        "status": {
            "active",
            "inactive",
        }
    },

    "products": {
        "status": {
            "active",
            "inactive",
            "discontinued",
        }
    },

    "orders": {
        "status": {
            "pending",
            "confirmed",
            "shipped",
            "completed",
            "cancelled",
        },
        "channel": {
            "web",
            "mobile_app",
            "social",
        },
    },

    "payments": {
        "payment_status": {
            "pending",
            "success",
            "failed",
            "refunded",
        },
        "payment_method": {
            "cash",
            "bank_transfer",
            "card",
            "e_wallet",
        },
    },
}

dirty_path = Path(__file__).resolve().parents[2] / "data/dirty/day_2026-07-02"
print(dirty_path)

def split_valid_invalid(name, df):
    e = []
    """TODO Buổi 7: row-level rules.
    Gợi ý: email, enum status/channel/method, non-negative money,
    quantity > 0, discount <= quantity*unit_price, parseable required dates.
    Return: (valid_df, reject_df có error_code).
    """
    rejected_df = pd.DataFrame(columns=['error_code','cnt'])
    valid_df = pd.DataFrame(columns=['VALID_code','cnt'])
    if name == 'customers':      
        rejected_df.loc[0] = "INVALID_EMAIL"
        rejected_df.loc[0,"cnt"] = (~df["email"].str.match(EMAIL, na=False)).sum()
        valid_df.loc[0] = "VALID_EMAIL"
        valid_df.loc[0,"cnt"] = (df["email"].str.match(EMAIL, na=False)).sum()
    if name == "products":
        rejected_df.loc[len(rejected_df)] = ["INVALID_STATUS",(~df['status'].isin(list(VALID['products']['status']))).sum()]
        valid_df.loc[len(rejected_df)] =    ["VALID_STATUS",(df['status'].isin(list(VALID['products']['status']))).sum()]
        rejected_df.loc[len(rejected_df)] = ["NEGATIVE_PRICE",(df.query("unit_price<0")).shape[0]]
        valid_df.loc[len(rejected_df)] =    ["POSSITIVE_PRICE",(df.query("unit_price>=0")).shape[0]]

    if name == 'orders':
        rejected_df.loc[len(rejected_df)] = ["INVALID_CHANNEL",(~df['channel'].isin(list(VALID['orders']['channel']))).sum()]
        valid_df.loc[len(rejected_df)] =    ["VALID_CHANNEL",(df['channel'].isin(list(VALID['orders']['channel']))).sum()]
        rejected_df.loc[len(rejected_df)] = ["INVALID_STATUS",(~df['status'].isin(list(VALID['orders']['status']))).sum()]
        valid_df.loc[len(rejected_df)] =    ["VALID_STATUS",(df['status'].isin(list(VALID['orders']['status']))).sum()]
        rejected_df.loc[len(rejected_df)] = ["NEGATIVE_ORDER_TOTAL",(df.query("order_total<0")).shape[0]]
        valid_df.loc[len(rejected_df)] =    ["POSSITIVE_ORDER_TOTAL",(df.query("order_total>=0")).shape[0]]

    if name == 'payments':
        rejected_df.loc[len(rejected_df)] = ["INVALID_PAYMENT_STATUS",(~df['payment_status'].isin(list(VALID['payments']['payment_status']))).sum()]
        valid_df.loc[len(rejected_df)] =    ["VALID_PAYMENT_STATUS",(df['payment_status'].isin(list(VALID['payments']['payment_status']))).sum()]
        rejected_df.loc[len(rejected_df)] = ["INVALID_PAYMENT_METHOD",(~df['payment_method'].isin(list(VALID['payments']['payment_method']))).sum()]
        valid_df.loc[len(rejected_df)] =    ["VALID_PAYMENT_METHOD",(df['payment_method'].isin(list(VALID['payments']['payment_method']))).sum()]
        rejected_df.loc[len(rejected_df)] = ["NEGATIVE_ORDER_TOTAL",(df.query("amount<0")).shape[0]]
        valid_df.loc[len(rejected_df)] =    ["POSSITIVE_ORDER_TOTAL",(df.query("amount>=0")).shape[0]]

    if name == 'order_items':
        rejected_df.loc[len(rejected_df)] = ["NEGATIVE_QUANTITY",(df.query("quantity<0")).shape[0]]
        valid_df.loc[len(rejected_df)] =    ["POSSITIVE_QUANTITY",(df.query("quantity>=0")).shape[0]]
        rejected_df.loc[len(rejected_df)] = ["NEGATIVE_ORDER_PRICE",(df.query("unit_price<0")).shape[0]]
        valid_df.loc[len(rejected_df)] =    ["POSSITIVE_ORDER_PRICE",(df.query("unit_price>=0")).shape[0]]
        rejected_df.loc[len(rejected_df)] = ["NEGATIVE_DISCOUNT_AMOUNT",(df.query("discount_amount<0")).shape[0]]
        valid_df.loc[len(rejected_df)] =    ["POSSITIVE_DISCOUNT_AMOUNT",(df.query("discount_amount>=0")).shape[0]]
        rejected_df.loc[len(rejected_df)] = ["DISCOUNT_EXCEEDS_GROSS",(df.query("discount_amount>quantity*unit_price")).shape[0]]
        valid_df.loc[len(rejected_df)] =    ["DISCOUNT_LESSER_GROSS",(df.query("discount_amount<=quantity*unit_price")).shape[0]]

    for _,i in rejected_df.iterrows():
       e.append(f"{i['error_code']}: {i['cnt']}\n")
       
    return e

customers = pd.read_csv(dirty_path / "customers_daily.csv")
products = pd.read_csv(dirty_path / "products_daily.csv")
orders = pd.read_csv(dirty_path / "orders_daily.csv")
order_items = pd.read_csv(dirty_path / "order_items_daily.csv")
payments = pd.read_json(dirty_path / "payments_daily.json")

    
