
from .logger import get_logger
import time
import requests
from .config import SETTINGS
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import json
from datetime import datetime

logger = get_logger()

def build_session(): #dùng để tạo một phiên HTTP (requests.Session) đã được cấu hình sẵn retry, để các request có thể dùng lại cấu hình đó thay vì phải thiết lập lại từ đầu.
    retry = Retry(
        total=3,
        backoff_factor=2,
        status_forcelist=[500, 501, 502, 503, 504],
        allowed_methods=["GET"],
        raise_on_status=False,
    )

    adapter = HTTPAdapter(max_retries=retry)

    session = requests.Session()
    session.mount("http://", adapter)
    session.mount("https://", adapter)

    return session

MAX_RETRIES = 3
BACKOFF_SECONDS = 2


def fetch_all_pages (resource, page = 1, page_size=100,updated_after=None):
    url = f"{SETTINGS.api_url.rstrip('/')}/{resource}"
    rows = []
    params = {
        "page": page,
        "page_size": page_size,
    }

    if updated_after is not None:
        params["updated_after"] = updated_after

    attempt = 1
    session = build_session()
    
    try:
        while True:
            attempt = 1
            params["page"] = page

            while attempt <= MAX_RETRIES:
                try:
                    response = session.get(
                                            url,
                                            headers={"X-API-Key": SETTINGS.api_key},
                                            params=params,
                                            timeout=10,
                                            )

                    response.raise_for_status()
                    payload = response.json()
                    rows.extend(payload["data"])
                    has_next = payload.get("has_next", False)
                    break

                except (requests.RequestException, ValueError) as exc:
                    logger.warning(
                                    "Request failed: resource=%s, page=%s, "
                                    "attempt=%s/%s, error=%s",
                                    resource, page, attempt, MAX_RETRIES, exc)
            
                    if attempt >= MAX_RETRIES:
                        raise RuntimeError(
                                            f"API failed after {MAX_RETRIES} attempts: "
                                            f"{resource} page {page}"
                                            ) from exc
                
                    time.sleep(BACKOFF_SECONDS * (2 ** (attempt - 1)))
                    attempt += 1
            if not has_next:
                logger.info(
                                "resource=%s page=%s rows=%s",
                                resource,
                                page,
                                len(rows)
                        )
                return rows
            page += 1

    finally:
        session.close()

def save_raw_rows(rows, resource,run_id=None):
    if run_id is None:
        run_id = datetime.now().strftime("%Y%m%d_%H%M%S")

    output_dir = SETTINGS.raw_dir / run_id
    output_dir.mkdir(parents=True, exist_ok=True)

    path = output_dir / f"{resource}.json"

    payload = {
                "resource": resource,
                "run_id": run_id,
                "data": rows,
                }
    path.write_text(
                    json.dumps(
                    payload,
                    ensure_ascii=False,
                    indent=2,
                    default=str,
                    ),
                    encoding="utf-8",
                    ) 
    logger.info("Saved RAW data: %s", path)

    


            
        
            

