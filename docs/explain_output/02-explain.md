
INDEX giúp tăng tốc độ truy vấn vì nó tạo ra cấu trúc dữ liệu phụ để tìm kiếm nhanh hơn thay vì quét toàn bộ bảng. Khi một cột thường xuyên xuất hiện trong WHERE hoặc dùng để JOIN, việc có INDEX sẽ giảm số bản ghi phải duyệt, từ đó cải thiện hiệu năng.


DROP TABLE IF EXISTS temp_items;
CREATE TEMP TABLE temp_items AS

select a.*, case when order_total = a.total_order_items then 'MATCH' else 'DIFF vì discount' end as comment from (
select o.order_id, o.customer_id, o.order_total, sum(oi.quantity * oi.unit_price) as total_order_items from core.orders o
join core.order_items oi using (order_id)
group by o.order_id, o.customer_id, o.order_total) a;

EXPLAIN ANALYZE
select comment, COUNT(*) AS cnt
FROM temp_items
GROUP BY comment;

After:
Planning Time: 0.849 ms  
Execution Time: 1.681 ms 


EXPLAIN ANALYZE
select * from temp_items limit 10;

After:
Planning Time: 0.039 ms   
Execution Time: 0.014 ms  

