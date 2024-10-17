CREATE DATABASE dannys_dinner ;
USE dannys_dinner;


CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INT 
  );
  
  
  CREATE TABLE members 
(
customer_id VARCHAR(1),  
join_date DATE); 
  


INSERT INTO sales (customer_id, order_date, product_id)
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
 
 INSERT INTO menu (product_id, product_name, price)
 VALUES
 ('1', 'sushi', '10'),
 ('2', 'curry', '15'),
 ('3', 'ramen', '12');
 
 
 INSERT INTO members  
(customer_id, join_date)
VALUES  
('A', '2021-01-07'),  
('B', '2021-01-09');
 

SELECT * FROM sales;
SELECT * FROM members;
SELECT * FROM menu;




#--1
SELECT customer_id, SUM(price) AS amount_spent 
FROM sales 
JOIN menu 
ON menu.product_id = sales.product_id
GROUP BY customer_id;

#--2
SELECT customer_id, COUNT(DISTINCT(order_date)) AS number_of_visits
FROM sales
GROUP BY customer_id;


#--3
SELECT DISTINCT(customer_id), product_name FROM sales s
JOIN menu m 
ON m.product_id = s.product_id
WHERE s.order_date = '2021-01-01';


#--4
SELECT menu.product_name, COUNT(sales.product_id) AS most_purchased_item
FROM menu
JOIN sales
ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY most_purchased_item DESC
LIMIT 1;


#--5
SELECT s.customer_id, m.product_name, COUNT(m.product_name) AS most_purchased_item
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id, product_name
ORDER BY  most_purchased_item DESC;



#--6
SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON s.customer_id = mem.customer_id
WHERE order_date > join_date
ORDER BY order_date 
LIMIT 2;

#--7
SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON s.customer_id = mem.customer_id
WHERE order_date < join_date
ORDER BY order_date 
LIMIT 2;


#--8
SELECT s.customer_id, SUM(m.price) AS total_amount_spent, COUNT(s.product_id) AS total_items_bought
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON s.customer_id = mem.customer_id
WHERE order_date < join_date
GROUP BY customer_id;


#9
SELECT customer_id, SUM(
CASE
WHEN product_name = 'sushi' THEN 20 * price
ELSE 10 * price
END)
AS total_points
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id;

#--10
WITH total_points AS 
(
SELECT s.customer_id, m.join_date, s.order_date, date_add(m.join_date, interval(6) DAY) firstweek_ends, menu.product_name, menu.price
FROM sales s
JOIN members m
ON s.customer_id = m.customer_id
JOIN menu
ON s.product_id = menu.product_id)
SELECT customer_id,
SUM(CASE
WHEN order_date BETWEEN join_date AND firstweek_ends THEN 20 * price 
WHEN (order_date NOT BETWEEN join_date AND firstweek_ends) AND product_name = 'sushi' THEN 20 * price
ELSE 10 * price
END) points
FROM total_points
WHERE order_date < '2021-02-01'
GROUP BY customer_id;


#BONUS
#--1
SELECT s.customer_id, s.order_date, m.product_name, m.price,
CASE 
WHEN s.order_date >= mem.join_date THEN 'Y' 
WHEN s.order_date < mem.join_date THEN 'N' 
ELSE 'N'
END AS member
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
LEFT JOIN members mem
ON s.customer_id = mem.customer_id;

#--2
WITH Member_ranking AS
(
SELECT s.customer_id, s.order_date, m.product_name, m.price, 
CASE
WHEN s.order_date >= mem.join_date THEN 'Y' 
WHEN s.order_date < mem.join_date THEN 'N'
END AS member
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
LEFT JOIN members mem
ON s.customer_id = mem.customer_id
)
SELECT *, 
CASE
WHEN member = 'N' THEN NULL 
ELSE RANK() OVER w
END AS ranking
FROM Member_ranking
WINDOW w AS (PARTITION BY s.customer_id, member ORDER BY s.order_date)