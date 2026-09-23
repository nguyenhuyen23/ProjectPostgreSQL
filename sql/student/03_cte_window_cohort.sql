WITH CTE1 AS (
    SELECT o.customer_id, SUM(order_total) AS revenue 
    FROM core.orders o 
    GROUP BY o.customer_id
),
CTE2 AS (
    SELECT a.*, 
           CASE 
             WHEN revenue < 100000000 THEN 'Low'
             WHEN revenue >= 100000000 AND revenue < 150000000 THEN 'Medium'
             WHEN revenue >= 150000000 THEN 'High'
           END AS classify 
    FROM CTE1 a
),
orders_per_customer AS (
    SELECT o.customer_id, COUNT(*) total_orders 
    FROM core.orders o
    GROUP BY o.customer_id
),
customer_stats AS (
    SELECT MAX(total_orders) AS max_orders,
           AVG(total_orders) AS avg_orders 
    FROM orders_per_customer
),
aov AS (
    SELECT b.customer_id, revenue/total_orders AS avg_order_value 
    FROM orders_per_customer a
    JOIN CTE1 b ON b.customer_id = a.customer_id
),
cohort AS (
    SELECT customer_id, MIN(DATE_TRUNC('month', order_date)) AS min_date 
    FROM core.orders o
    GROUP BY customer_id
),
orders_next AS (
    SELECT o.customer_id, DATE_TRUNC('month', o.order_date) AS order_month
    FROM core.orders o
    JOIN cohort c ON o.customer_id = c.customer_id
    WHERE DATE_TRUNC('month', o.order_date) > c.min_date
)
SELECT 
    c.min_date,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.customer_id) AS retained_customers,
    COUNT(DISTINCT o.customer_id) * 1.0 / COUNT(DISTINCT c.customer_id) AS retention_rate
FROM cohort c
LEFT JOIN orders_next o ON c.customer_id = o.customer_id
GROUP BY c.min_date
ORDER BY c.min_date;


--- ROW_NUMBER() OVER (ORDER BY total_spending DESC): rank customers.

select a.*, ROW_NUMBER() OVER (ORDER BY total_spending DESC) as "rank customer" from (
select customer_id, sum(order_total) as total_spending from core.orders a
group by customer_id) a;

--- RANK() vs DENSE_RANK(): top 3 customers - giải thích khác biệt gap trong comment (ví dụ đồng hạng thì RANK nhảy số).

/* rank: Gán cùng thứ hạng cho các dòng có giá trị bằng nhau và Sau đó bỏ qua số thứ tự tiếp theo. */
/* Dense_rank: Gán cùng thứ hạng cho các dòng có giá trị bằng nhau và Không bỏ qua số thứ tự tiếp theo. */

select * from (
select a.*, ROW_NUMBER() OVER (ORDER BY total_spending DESC) as "rn",
Dense_rank() OVER (ORDER BY total_spending DESC) as "dr" ,
Rank() OVER (ORDER BY total_spending DESC) as "rank" 
from (
select customer_id, sum(order_total) as total_spending from core.orders a
group by customer_id) a) a
where 1 =2 
 	or rn != dr
 	or rn != rank
limit 10
;

--- ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date): số thứ tự order của mỗi customer.

select a.*, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as rn from core.orders a

--- LAG()/LEAD(): so sánh total_amount với order trước/sau của cùng customer + cột chênh lệch.

select a.*, lead - order_total as diff_lead, lag - order_total as diff_lg from (
select a.order_id, a.customer_id, a.order_date, order_total, lead(order_total) over(partition by customer_id order by order_date desc) as lead,
lag(order_total) over(partition by customer_id order by order_date desc) as lag
from core.orders a
order by a.customer_id , order_date) a;

--- SUM(total_amount) OVER (ORDER BY order_date): running total cumulative revenue.

select a.month, SUM(total_spending) OVER (ORDER BY a.month) from (
select date_trunc('month',order_date) as month, sum(order_total) as total_spending from core.orders a
group by date_trunc('month',order_date)) a

--- Customer Analytics - RFM 3 metrics trong 1 bảng
select * from (
select o.customer_id, EXTRACT(DAY FROM (NOW() - MAX(o.order_date))) as recency_days, COUNT(order_id) as frequency, SUM(order_total) as monetory from core.orders o 
where order_total is not null
group by o.customer_id, (now() - order_date))a
where recency_days > 0;