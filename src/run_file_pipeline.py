from pathlib import Path
from src.config import SETTINGS
from src.extract_files import read_dataset, profile
from src.transform import normalize
from src.logger import get_logger

logger = get_logger()

FILES = [
    "customers_daily.csv",
    "products_daily.csv",
    "orders_daily.csv",
    "order_items_daily.csv",
    "payments_daily.json",
]

def process_one(path: Path):
    logger.info("start dataset=%s", path.name)

    raw_df = read_dataset(path)
    before = profile(raw_df)

    logger.info(
        "profile dataset=%s rows=%s missing=%s duplicates=%s",
        path.name,
        before["rows"],
        sum(before["missing"].values()),
        before["duplicates"],
    )

    clean_df = normalize(raw_df)
    output_path = SETTINGS.staging_dir / f"{path.stem}_clean.csv"
    clean_df.to_csv(output_path, index=False)

    logger.info(
        "success dataset=%s rows_in=%d rows_out=%d output=%s",
        path.name,
        len(raw_df),
        len(clean_df),
        output_path,
    )

def main():
    logger.info("pipeline started")

    for file_name in FILES:
        path = SETTINGS.raw_dir / file_name
        try:
            process_one(path)
        except Exception:
            logger.exception("failed dataset=%s", file_name)
            raise

    logger.info("pipeline success")


if __name__ == "__main__":
    main()

