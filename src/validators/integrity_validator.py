import re
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine, text

database_url = 'postgresql+psycopg://de_user:de_password@localhost:5432/ecommerce'

engine = create_engine(database_url, pool_pre_ping=True)

dirty_path = Path(__file__).resolve().parents[2] / "data/dirty/day_2026-07-02"
reject_path = Path(__file__).resolve().parents[2] / "data/reject"
print(dirty_path)

customers = pd.read_csv(dirty_path / "customers_daily.csv")
products = pd.read_csv(dirty_path / "products_daily.csv")
orders = pd.read_csv(dirty_path / "orders_daily.csv")
order_items = pd.read_csv(dirty_path / "order_items_daily.csv")
payments = pd.read_json(dirty_path / "payments_daily.json")

def split_cross_table_invalid(name, df,reference_id=None):
    """TODO Buổi 7: cross-table integrity.

    Rules tối thiểu:
    products.category_id -> categories.category_id
    orders.customer_id -> customers.customer_id
    order_items.order_id -> orders.order_id
    order_items.product_id -> products.product_id
    payments.order_id -> orders.order_id
    payment_date >= order_date
    """
    list_error = []
    with engine.connect() as conn:
        if name == 'products':
            sql = text(f"SELECT category_id FROM core.categories")
            result_product = conn.execute(sql)
            reference_ids = [row[0] for row in result_product.fetchall()]
            product_key = df[~df[reference_id].isin(reference_ids)][['product_id','category_id']].copy()
            for _,i in product_key.iterrows():
                list_error.append(f"products product_id={i['product_id']} category_id={i['category_id']} NOT FOUND (FK_PRODUCT_NOT_FOUND)")

        if name == 'orders':
            sql = text(f"SELECT customer_id FROM core.customers")
            result_customer = conn.execute(sql)
            customer_ids = customers['customer_id'].to_list()
            customer_key = df[~df[reference_id].isin(customer_ids)][['order_id','customer_id']].copy()
            for _,i in customer_key.iterrows():
                list_error.append(f"orders order_id={i['order_id']} customer_id={i['customer_id']} NOT FOUND (FK_ORDER_NOT_FOUND)")

        if name == "order_items" and reference_id == "order_id":
            sql = text(f"SELECT order_id FROM core.orders")
            result_orders = conn.execute(sql)
            order_ids = orders['order_id'].to_list()
            order_key = df[~df[reference_id].isin(order_ids)][['order_item_id','order_id']].copy()
            for _,i in order_key.iterrows():
                list_error.append(f"order_items order_item_id={i['order_item_id']} order_id={i['order_id']} NOT FOUND (FK_ORDER_ITEM_NOT_FOUND)")

        if name == "order_items" and reference_id == "product_id": 
            sql = text(f"SELECT product_id FROM core.products") 
            result_products = conn.execute(sql)
            product_ids = products['product_id'].to_list()
            product_key = df[~df[reference_id].isin(product_ids)][['order_item_id','product_id']].copy()
            for _,i in product_key.iterrows():
                list_error.append(f"order_items order_item_id={i['order_item_id']} product_id={i['product_id']} NOT FOUND (FK_ORDER_ITEM_NOT_FOUND)") 

        if name == 'payments':
            sql = text(f"SELECT order_id, order_date FROM core.orders")
            result_payment = conn.execute(sql)
            df_orders = orders[['order_id','order_date']]
            payment_ids = df_orders['order_id'].tolist()
            payment_key = df.loc[~df[reference_id].isin(payment_ids),['payment_id', reference_id, 'payment_date']].copy() 
            merge_df = pd.merge(df,df_orders, on ="order_id",how='inner')
            compare_df = merge_df.query("payment_date>order_date")
            compare_df.to_csv( reject_path / "reject_payment_date.csv",index=False)

            for _,i in payment_key.iterrows():
                list_error.append(f"payments payment_id={i['payment_id']} order_id={i['order_id']} NOT FOUND (FK_PAYMENT_NOT_FOUND)")  

        return list_error
            

