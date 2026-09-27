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

--- 1.4 Cohort Analysis - Retention theo tháng


with first_orders as (select customer_id, date_trunc('Month',min(order_date)) as first_order 
					 from core.orders
				     group by customer_id),
cohort_month as (			  
select b.customer_id, (Extract(year from order_date)*12 + Extract(month from order_date)) - (Extract(year from first_order)*12 + Extract(month from first_order)) as month_no,
first_order 
from core.orders a
join first_orders b on a.customer_id  = b.customer_id)

select first_order ,
count(distinct case when month_no = 0 then customer_id end) as m0,
round(count(distinct case when month_no = 1 then customer_id end) :: numeric/ count(distinct case when month_no = 0 then customer_id end):: numeric *100.0,2) as m1,
round(count(distinct case when month_no = 2 then customer_id end) :: numeric/ count(distinct case when month_no = 0 then customer_id end):: numeric *100.0,2) as m2,
round(count(distinct case when month_no = 3 then customer_id end) :: numeric/ count(distinct case when month_no = 0 then customer_id end):: numeric *100.0,2) as m3
from cohort_month a
group by first_order 


with rfm_bucket as (
			select customer_id,
			EXTRACT(DAY FROM (NOW() - MAX(order_date))) as Recency,
			COUNT(order_id) as Frequency,
			SUM(o.order_total) as Monetary
			from core.orders o 
			group by customer_id),
			
rfm_scores as (select customer_id, Monetary, Monetary/Nullif(Frequency,0) * Frequency as aov_freq,
		concat(CASE WHEN Recency <= 30 THEN 5
         WHEN Recency <= 90 THEN 4
         WHEN Recency <= 180 THEN 3
         WHEN Recency <= 365 THEN 2
         ELSE 1 end,         
		   CASE WHEN frequency >= 10 THEN 5
         WHEN frequency >= 5 THEN 4
         WHEN frequency >= 3 THEN 3
         WHEN frequency >= 2 THEN 2
         ELSE 1 END,
         CASE WHEN monetary >= 150000000 THEN 5
         WHEN monetary >= 100000000 THEN 4
         WHEN monetary >= 50000000 THEN 3
         WHEN monetary >= 25000000 THEN 2
         ELSE 1 end) as RFM
from rfm_bucket)

select * from rfm_scores
limit 20

with revenue as (
select order_date :: date as order_date, sum(order_total) as total_rev from core.orders
group by order_date :: date )


select order_date, round((a.current_rev -a.previous_rev )/NULLIF(previous_rev,0) * 100.0,2) as mom_growth, 
round(avg(a.current_rev) over(order by order_date rows between 6 preceding and current row),2) AS ma_7day,
round(avg(a.current_rev) over(order by order_date rows between 29 preceding and current row),2) AS ma_30day
from (
select order_date, total_rev as current_rev, lag (total_rev)over(order by order_date) as previous_rev from revenue a
order by order_date) a