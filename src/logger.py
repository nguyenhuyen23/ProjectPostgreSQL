import logging
from pathlib import Path
from src.config import SETTINGS


def get_logger(name='pipeline'):
    # TODO: Buổi 5 - cấu hình file handler + console handler, format timestamp/level/name/message.
    Path(SETTINGS.log_dir).mkdir(exist_ok=True)
    logger = logging.getLogger(name)
    if logger.handlers:
        return logger
    logger.setLevel(logging.INFO)
    fmt = logging.Formatter("%(asctime)s | %(levelname)s | %(name)s | %(message)s")
    fh = logging.FileHandler(Path(SETTINGS.log_dir) / "pipeline.log", encoding="utf-8")
    fh.setFormatter(fmt)
    sh = logging.StreamHandler()
    sh.setFormatter(fmt)
    logger.addHandler(fh)
    logger.addHandler(sh)
    return logger
