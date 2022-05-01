CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


 

--1. WHAT IS THE TOTAL AMOUNT EACH CUSTOMER SPENT AT THE RESTAURANT
  select customer_id,sum(price)total_amount
  from sales
  join menu
  on sales.product_id = menu.product_id
  GROUP BY customer_id;

  --2. HOW MANY DAYS HAS EACH CUSTOMER VISITED THE RESTAURANT
  select customer_id, count(distinct order_date)visit
  from sales
  group by customer_id;


  --3. WHAT WAS THE FIRST ITEM PURCHASED BY EACH CUSTOMER
 
 with ctereports as
 (select order_date,customer_id,product_name,dense_rank() over(partition by customer_id order by order_date)product
  from sales
  join menu
  on sales.product_id = menu.product_id)
select order_date,customer_id,product_name
from ctereports
where product = 1
  --4. WHAT WAS THE MOST PURCHASED ITEM AND HOW MANY TIMES
 
 with cte_table as
  (select product_name, count(s.product_id) total
  from menu m
  join sales s
  on m.product_id = s.product_id
  group by product_name)
select top 1 product_name,total
from cte_table
order by total desc; 
 

  --5. WHICH ITEM WAS THE MOST POPULAR FOR EACH CUSTOMER
 with cte_rate as
  (select s.customer_id,product_name,count(product_name)frequency,dense_rank() over(partition by customer_id order by count(product_name) desc)count
  from sales s
  join menu m
  on s.product_id = m.product_id
  group by s.customer_id,product_name)
select customer_id,product_name
from cte_rate
where count = 1


--6. WHICH ITEM WAS PURCHASED FIRST BY THE CUSTOMER AFTER THEY BECAME A MEMBER
with cte_dinner as
 (select m.customer_id, join_date,order_date,product_name,dense_rank()over(partition by m.customer_id order by order_date) rank
 from members m
 join sales s
 on m.customer_id =s.customer_id
 join menu
 on s.product_id = menu.product_id
 where order_date > join_date)
select customer_id, product_name
from cte_dinner
where rank = 1




 --7. WHICH ITEM WAS PURCHASED JUST BEFORE THE CUSTOMER BECAME A MEMBER
 with cte_dinner as
 (select m.customer_id, join_date,order_date,product_name,dense_rank()over(partition by m.customer_id order by order_date) rank
 from members m
 join sales s
 on m.customer_id =s.customer_id
 join menu
 on s.product_id = menu.product_id
 where order_date < join_date)
select customer_id, product_name
from cte_dinner
where rank = 1


 
 --8. WHAT IS THE TOTAL ITEMS AND AMOUNT SPENT FOR EACH MEMBER BEFORE THEY BECAME A MEMBER
 select s.customer_id,count(product_name) total_items,concat('$',sum(price)) amount_spent
 from menu m
 join sales s
 on m.product_id = s.product_id
 join members mem
 on mem.customer_id = s.customer_id
 where order_date < join_date
 group by s.customer_id
 order by s.customer_id

 --9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

 SELECT customer_id,
       SUM(CASE
               WHEN product_name = 'sushi' THEN price*20
               ELSE price*10
           END) AS customer_points
FROM menu AS m
INNER JOIN sales AS s ON m.product_id = s.product_id
GROUP BY customer_id
ORDER BY customer_id;

SELECT s.customer_id,
       SUM(CASE
               WHEN product_name = 'sushi' THEN price*20
               ELSE price*10
           END) AS customer_points
FROM menu AS m
INNER JOIN sales AS s ON m.product_id = s.product_id
INNER JOIN members AS mem ON mem.customer_id = s.customer_id
WHERE order_date >= join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

	