/* 1.3. JOIN Operations - 5 queries JOIN */

-- Liệt kê orders kèm customer_name, customer_email (orders JOIN customers).

select o.order_id,o.customer_id , full_name, email from core.orders o
JOIN core.customers using (customer_id)
limit 10;

-- Chi tiết từng order_item kèm product_name, price (order_items JOIN products).

select oi.*, p.product_name , p.unit_price  from core.order_items oi 
join core.products p using (product_id) limit 10;

-- Orders có payments nhưng chưa có order_items (hoặc ngược lại) - dùng LEFT JOIN + IS NULL 1 phía.

select * from core.orders o
join core.payments p on o.order_id = p.order_id
left join core.order_items a on o.order_id = a.order_id
where a.order_item_id is null

-- Products chưa từng được bán (products LEFT JOIN order_items ... WHERE order_items.id IS NULL).

select * from core.products p 
left join core.order_items oi on p.product_id  = oi.product_id 
where oi.order_id is null

-- Đối soát: total order value = SUM(order_items quantity*price) theo từng order (GROUP BY order_id), so với orders.total_amount.
DROP TABLE IF EXISTS temp_items;
CREATE TEMP TABLE temp_items AS

select a.*, case when order_total = a.total_order_items then 'MATCH' else 'DIFF vì discount' end as comment from (
select o.order_id, o.customer_id, o.order_total, sum(oi.quantity * oi.unit_price) as total_order_items from core.orders o
join core.order_items oi using (order_id)
group by o.order_id, o.customer_id, o.order_total) a;

select comment, COUNT(*) AS cnt
FROM temp_items
GROUP BY comment;

select * from temp_items limit 10;