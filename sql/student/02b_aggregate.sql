/* 1.2. Aggregate & Grouping - 5 queries GROUP BY/HAVING */

-- Tổng doanh thu theo từng tháng (EXTRACT(MONTH FROM order_date) hoặc DATE_TRUNC('month', ...)).

select date_trunc('month', order_date) as month, sum (order_total) "Doanh thu theo thang" from core.orders o
group by date_trunc('month', order_date)
order by month;

-- Trung bình giá trị đơn hàng theo từng customer (AVG(total_amount) GROUP BY customer_id).

select o.customer_id , round(avg(o.order_total),2)::int as avg_amnt from core.orders o
join core.customers c using(customer_id) 
group by o.customer_id
order by avg_amnt desc;

-- Số lượng đơn hàng theo từng order_status.

select os.status_code, count(*) as cnt from core.order_status os 
join core.orders o on os.status_code = o.status 
group by os.status_code;

-- Tổng doanh thu theo category (JOIN order_items → products → categories).

select c.category_name , sum(oi.quantity * oi.unit_price) as "Tong doanh thu" from core.order_items oi 
join core.products p using(product_id)
join core.categories c using(category_id)
group by c.category_name;

-- HAVING: categories có tổng doanh thu > 1000.

select c.category_name , sum(oi.quantity * oi.unit_price) as "Tong doanh thu" from core.order_items oi 
join core.products p using(product_id)
join core.categories c using(category_id)
group by c.category_name
having sum(oi.quantity * oi.unit_price) > 1000;