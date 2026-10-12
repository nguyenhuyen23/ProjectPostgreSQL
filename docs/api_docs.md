Mock REST API Documentation

1. Overview

Base URL: http://localhost:8000
Protocol: HTTP
-API-KeyAPI Key Header: X-API-Key
Health Check: GET /health
content-type: application/json

Expected response:
status: 200
HTTP/1.1 200 OK
{"status": "ok"}

or 

status: 401
HTTP/1.1 400 Bad Request

HTTP 			status				Meaning	Expected response
200 OK			Request succeeded		Successful response body
curl.exe -i -H "X-API-Key: **********" "http://localhost:8000/customers?page=1&page_size=5"
400 Bad Request		Invalid timestamp format	{"detail":"updated_after must be ISO 8601"}
curl.exe -i "http://localhost:8000/customers?page=1&page_size=10"
401 Unauthorized	Missing or invalid API key	{"detail":"Invalid API key"}
curl.exe -i -H "X-API-Key: wrong_key" "http://localhost:8000/customers?page=1&page_size=10"

2. Authentication and Security

Protected endpoints require the X-API-Key request header.
The API key is configured using the MOCK_API_KEY environment variable. The default value is masked as ****** in this documentation.
X-API-Key: ******
Never expose the actual API key in logs, screenshots, source control, or documentation.

3. Health Check

Health Check
GET /health
Checks whether the Mock API is available.

Expected success response:

HTTP 200 OK

{
  "status": "ok"
}

4. Business Endpoints

Pay attention to the paths, especially those containing slashes.
/customers, 
/products, 
/orders, 
/order-items,
/payments

5. Request Parameters

Supported parameters for endpoints where pagination is enabled:

Parameter	Type	         Constraint	Default
page		Integer	            >= 1	Verify implementation
page_size	Integer	           1–500	100

exp: GET/orders?page=1&page_size=10

Response Structure

{"page":1,"page_size":10,"total":600,"has_next":true,"data":[]}

6. Incremental Filtering

Parameter	Type			Description
updated_after	ISO 8601 timestamp	Filters records updated after the specified timestamp, where supported

exp: ?updated_after=2026-07-01T12:00:00Z
if it is not ISO 8601 timestamp, 
expected response:
status: 400 Bad Request
msg: {"detail":"updated_after must be ISO 8601"}

7. Verification
Record the observed response status, response body, pagination metadata, and supported parameters for each endpoint after testing the running Mock API.
See docs/evidence/06-explore-log.txt for test evidence.