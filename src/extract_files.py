from pathlib import Path
import pandas as pd
import json


def read_dataset(path: Path) -> pd.DataFrame:
    if not path.exists():
        raise FileNotFoundError(f"Missing file: {path}")
    
    if path.suffix.lower() not in [".csv", ".json"]:
        raise ValueError(f"Unsupported file: {path}") 
    
    if path.suffix.lower() == ".csv":
        df =  pd.read_csv(path,encoding="utf-8")

    elif path.suffix.lower() == ".json":
        obj = json.loads(path.read_text(encoding="utf-8"))
        df = pd.DataFrame(
                        obj if isinstance(obj, list)
                        else obj.get("data", []) )
    if len(df) == 0:
        raise ValueError(f"Empty dataset: {path}")
    return df



def profile(df: pd.DataFrame) -> dict:        
    if len(df) != 0:
        return {
            "rows": len(df),
            "columns": list(df.columns),
            "missing": df.isna().sum().to_dict(),
            "duplicates": int(df.duplicated().sum()),
             }
    else:
        raise ValueError("DataFrame is empty")
