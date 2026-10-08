import pandas as pd


def normalize(df: pd.DataFrame) -> pd.DataFrame:
    out = df.copy()
    out.columns = [c.strip().lower() for c in out.columns]
    for col in out.columns:
        if out[col].dtype == 'object':
            out[col] = out[col].apply(lambda a: a.strip() if isinstance(a,str) else a)
        if col == 'email':
            out[col] = out[col].str.strip().str.lower()
        if col in ['status', 'payment_status', 'payment_method','channel']:
            out[col] = out[col].str.strip().str.lower()
        if col in ['unit_price', 'cost_price','order_total', 'discount_amount', 'amount', 'quantity']:
            out[col] = pd.to_numeric(out[col],errors="coerce")
        if col.endswith('at') or col.endswith('date'):
            out[col] = pd.to_datetime(out[col],errors="coerce",utc=True)
    return out