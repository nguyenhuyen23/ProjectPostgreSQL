-- Query cumulative revenue theo thời gian (SUM(revenue) OVER (ORDER BY month)).
select distinct date_trunc('month', order_date)  as month, SUM(o.order_total) OVER (ORDER BY date_trunc('month', order_date)) from core.orders o 
order by month ;

select c.category_name ,sum(oi.quantity * oi.unit_price) as revenue, round(SUM(oi.quantity * oi.unit_price) 
         / SUM(SUM(oi.quantity * oi.unit_price)) OVER () * 100,2) AS revenue_share_percent from core.order_items oi 
join core.products p on p.product_id = oi.product_id 
join core.categories c on c.category_id  = p.category_id 
group by c.category_name
order by revenue_share_percent desc;

with max_date as  (
	select max(order_date) as max_date from core.orders
)

select o.customer_id  from core.orders o, max_date m
group by o.customer_id, m.max_date
having max(o.order_date) < m.max_date - INTERVAL '30 days';