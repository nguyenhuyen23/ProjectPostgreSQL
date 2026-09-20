# Q1

select *
from (
    select date_trunc('month', order_date) as month, sum(o.order_total)
    from core.orders o
    group by date_trunc('month', order_date)
) a
where to_char(month, 'MM') = '07';

#|month                        |sum          |
-+-----------------------------+-------------+
1|2026-07-01 00:00:00.000 +0700|7226403500.00|

Total revenue tháng 7/2026: 7226403500.00

# Q2

select o.customer_id, c.full_name , sum(order_total) as tong_chi_tieu from core.orders o 
left join core.customers c on c.customer_id = o.customer_id 
group by o.customer_id, c.full_name
order by tong_chi_tieu desc
limit 1;

#|customer_id|full_name     |tong_chi_tieu|
-+-----------+--------------+-------------+
1|CUS000852  |Alfred Hubbard| 213551500.00|

# Q3

select c.category_name ,sum(quantity) as cnt from core.order_items oi 
join core.products p on p.product_id = oi.product_id 
join core.categories c on c.category_id  = p.category_id 
group by c.category_name
order by cnt desc
limit 1;

#|category_name|cnt |
-+-------------+----+
1|Skincare     |1714|

# Q4

SELECT AVG(order_total) AS average_order_value
FROM core.orders;

#|average_order_value  |
-+---------------------+
1|12309434.910714285714|

# Q5

#|average_order_value  |
-+---------------------+
1|12309434.910714285714|

#|cnt|
-+---+
1|912|