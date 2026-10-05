EXPLAIN ANALYZE
select month_num, dd.year_num, sum(t.gross_amount ) as total_rev from mart.fact_sales t 
join mart.dim_date dd using (date_key)
group by month_num, dd.year_num
order by dd.year_num desc, month_num;

|Planning Time: 0.215 ms   
|Execution Time: 5.178 ms  

EXPLAIN ANALYZE
select date_trunc('month',o.order_date)::date as order_date, round(sum(oi.unit_price * oi.quantity),2) as total_rev from core.orders o 
join core.order_items oi using(order_id)
group by date_trunc('month',o.order_date)
order by date_trunc('month',o.order_date)::date;

|Planning Time: 0.290 ms   
|Execution Time: 8.237 ms  

Conclusion: mart chạy nhanh hơn
