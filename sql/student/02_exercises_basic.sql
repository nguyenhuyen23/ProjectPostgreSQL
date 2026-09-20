
/* 1.1 Basic Queries - 5 queries SELECT/WHERE/ORDER BY */
-- Q1 - SELECT with filtering: tất cả orders có total_amount > 100.

select count(distinct order_id) as cnt from core.orders c
where c.order_total > 100 ;


-- Q2 - NULL handling: customers chưa có order nào (LEFT JOIN orders ... WHERE orders.id IS NULL)

select c.customer_id , c.full_name  from core.orders o
right join core.customers c on o.customer_id = c.customer_id 
where o.order_id is null;

-- Q3 - ORDER BY: top 10 customers theo tổng chi tiêu (tính từ bảng orders).

select * from core.orders o  order by o.order_total desc limit 10;

-- Q4 - COUNT/DISTINCT: đếm số customers khác nhau có đơn hàng (COUNT(DISTINCT customer_id)).

select COUNT(DISTINCT customer_id) as customer_cnt from core.orders o
join core.customers c using(customer_id) ;


select o.customer_id , count(o.order_id) as cnt from core.orders o
join core.customers c using(customer_id) 
group by o.customer_id
having count(o.order_id) > 3
order by cnt desc;

-- Q5 - LIMIT: 5 orders mới nhất theo order_date (ORDER BY order_date DESC LIMIT 5).

select * from core.orders o order by order_date desc limit 5;


