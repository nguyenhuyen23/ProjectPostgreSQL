-- KPI1
select month_num, dd.year_num, sum(t.gross_amount ) as total_rev from mart.fact_sales t 
join mart.dim_date dd using (date_key)
group by month_num, dd.year_num
order by dd.year_num desc, month_num;

--  KPI2

select category_name, sum(a.gross_amount ) as total_rev from mart.fact_sales a
JOIN mart.dim_product using (product_sk)
group by category_name;

--  KPI3

select c.product_id, sum(a.gross_amount ) as total_rev from mart.fact_sales a
JOIN mart.dim_product c using (product_sk)
group by c.product_id
order by total_rev desc
limit 10;

-- KPI4

select round(SUM(a.gross_amount)/COUNT(DISTINCT order_id),2) as AOV from mart.fact_sales a;

--  KPI5

select dc.customer_segment, count(distinct dc.customer_id) from mart.fact_sales a
join mart.dim_customer dc using(customer_sk)
group by dc.customer_segment;

EXPLAIN ANALYZE
select month_num, dd.year_num, sum(t.gross_amount ) as total_rev from mart.fact_sales t 
join mart.dim_date dd using (date_key)
group by month_num, dd.year_num
order by dd.year_num desc, month_num;

EXPLAIN ANALYZE
select date_trunc('month',o.order_date)::date as order_date, round(sum(oi.unit_price * oi.quantity),2) as total_rev from core.orders o 
join core.order_items oi using(order_id)
group by date_trunc('month',o.order_date)
order by date_trunc('month',o.order_date)::date;

