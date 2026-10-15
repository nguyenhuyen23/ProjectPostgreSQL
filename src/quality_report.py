import pandas as pd
import uuid
from pathlib import Path
from .config import SETTINGS

def build_report(dataset,
                input_count,
                valid_count,
                reject_count,
                error_codes=None,
                run_id=None,
                out_dir='reports'):
    if run_id is None:
        run_id = str(uuid.uuid4())
        valid_rate = (valid_count / input_count if input_count else 1.0)
        top_error = None
        if (error_codes is not None and len(error_codes) > 0):
            top_error = (pd.Series(error_codes).value_counts().index[0])
    return {
        "run_id": run_id,
        "dataset": dataset,
        "input": input_count,
        "valid": valid_count,
        "rejected": reject_count,
        "valid_rate": valid_rate,
        "top_error": top_error,
    }
input_count = 40
valid_count = 35
reject_count = 5
dataset = "customers"

assert (
    input_count == valid_count + reject_count
), (
    f"{dataset}: INPUT != VALID + REJECTED | "
    f"{input_count} != {valid_count} + {reject_count}"
)

print(
    f"{dataset}: INPUT = VALID + REJECTED | "
    f"{input_count} = {valid_count} + {reject_count}"
)

rows = [build_report(dataset,input_count,valid_count,reject_count),]

report = pd.DataFrame(rows)

report_dir = Path(SETTINGS.report_dir)
report_dir.mkdir(parents=True, exist_ok=True)

report_path = report_dir / "data_quality_report.csv"

report.to_csv(
    report_path,
    index=False
)
   
