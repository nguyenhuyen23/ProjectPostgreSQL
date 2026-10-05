-- KPI1
select month_num, dd.year_num, sum(t.gross_amount ) as total_rev from mart.fact_sales t 
join mart.dim_date dd using (date_key)
group by month_num, dd.year_num
order by dd.year_num desc, month_num;

#|month_num|year_num|total_rev     |
-+---------+--------+--------------+
1|        1|    2026|11166390000.00|
2|        2|    2026|10119000000.00|
3|        3|    2026|12338820000.00|
4|        4|    2026|10637950000.00|
5|        5|    2026|10890230000.00|
6|        6|    2026|10409650000.00|

--  KPI2

select category_name, sum(a.gross_amount ) as total_rev from mart.fact_sales a
JOIN mart.dim_product using (product_sk)
group by category_name;

# |category_name|total_rev    |
--+-------------+-------------+
1 |Sportswear   |3737680000.00|
2 |Home Decor   |4412530000.00|
3 |Personal Care|5015400000.00|
4 |Phones       |5270410000.00|
5 |Lifestyle    |3225150000.00|
6 |Makeup       |4128450000.00|
7 |Kitchen      |5619660000.00|
8 |Technology   |4199460000.00|
9 |Computers    |3882540000.00|
10|Fitness      |4922170000.00|
11|Skincare     |6503230000.00|
12|Outdoor      |3945100000.00|
13|Furniture    |3667580000.00|
14|Business     |3241670000.00|
15|Accessories  |3791010000.00|

--  KPI3

select c.product_id, sum(a.gross_amount ) as total_rev from mart.fact_sales a
JOIN mart.dim_product c using (product_sk)
group by c.product_id
order by total_rev desc
limit 10;

# |product_id|total_rev   |
--+----------+------------+
1 |PRD000297 |397500000.00|
2 |PRD000309 |373320000.00|
3 |PRD000203 |370560000.00|
4 |PRD000300 |364320000.00|
5 |PRD000173 |345400000.00|
6 |PRD000268 |326770000.00|
7 |PRD000355 |325080000.00|
8 |PRD000084 |316110000.00|
9 |PRD000016 |311200000.00|
10|PRD000126 |310200000.00|

-- KPI4

select SUM(a.gross_amount)/COUNT(DISTINCT order_id) as AOV from mart.fact_sales a;

#|aov        |
-+-----------+
1|13112408.00|

--  KPI5

select dc.customer_segment, count(distinct dc.customer_id) from mart.fact_sales a
join mart.dim_customer dc using(customer_sk)
group by dc.customer_segment;

#|customer_segment|count|
-+----------------+-----+
1|Gold            |  148|
2|Platinum        |   47|
3|Silver          |  238|
4|Standard        |  561|