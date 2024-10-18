**1. What is the total amount each customer spent at the restaurant?**
   ```sql
   SELECT customer_id, SUM(price) AS amount_spent 
   FROM sales 
   JOIN menu 
   ON menu.product_id = sales.product_id
   GROUP BY customer_id;
```
Output
| customer_id | amount_spent |
|---|---|
| A | 76 |
| B | 74 |
| C | 36 |


**2. How many days has each customer visited the restaurant?**
```sql
SELECT customer_id, COUNT(DISTINCT(order_date)) AS number_of_visits
FROM sales
GROUP BY customer_id;
```
Output:
| customer_id | number_of_visits |
|---|---|
| A | 4 |
| B | 6 |
| C | 2 |

**3.What was the first item from the menu purchased by each customer?**

 ```sql
   SELECT DISTINCT(customer_id), product_name FROM sales s
   JOIN menu m 
   ON m.product_id = s.product_id
   WHERE s.order_date = '2021-01-01';
 ```
Output:
| customer_id | product_name |
|---|---|
| A | sushi |
| B | curry |
| A | curry |
| C | ramen |


**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```sql
SELECT menu.product_name, COUNT(sales.product_id) AS most_purchased_item
FROM menu
JOIN sales
ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY most_purchased_item DESC
LIMIT 1;
```
Output
| product_name | most_purchased_item |
|---|---|
| ramen | 8 |


**5. Which item was the most popular for each customer?**
```sql
Which item was the most popular for each customer?
```
Output:
| customer_id | product_name | times_purchased |
|---|---|---|
| A | ramen | 3 |
| C | ramen | 3 |
| A | curry | 2 |
| B | curry | 2 |
| B | sushi | 2 |


**6. Which item was purchased first by the customer after they became a member?**
```sql
SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON s.customer_id = mem.customer_id
WHERE order_date > join_date
ORDER BY order_date 
LIMIT 2;
```
Output:
| customer_id | product_name |
|---|---|
| A | ramen |
| B | sushi |


**7. Which item was purchased just before the customer became a member?**
```sql
SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON s.customer_id = mem.customer_id
WHERE order_date < join_date
ORDER BY order_date 
LIMIT 2;
```
Output:
| customer_id | product_name |
|---|---|
| A | sushi |
| B | curry |


**8. What is the total items and amount spent for each member before they became a member?**
```sql
SELECT s.customer_id, SUM(m.price) AS total_amount_spent, COUNT(s.product_id) AS total_items_bought
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON s.customer_id = mem.customer_id
WHERE order_date < join_date
GROUP BY customer_id;
```
Output:
| customer_id | total_amount_spent | total_items_bought |
|---|---|---|
| B | 40 | 3 |
| A | 25 | 2 |


**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```sql
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
```
Output:
| customer_id | total_points |
|---|---|
| A | 860 |
| B | 940 |
| C | 360 |


**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
```sql
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
```
Output:
| customer_id | points |
|---|---|
| B | 820 |
| A | 1370 |


**Bonus Questions:**

Join All The Things

**1. Recreate the following table output using the available data:**

   <img width="283" alt="Screenshot 2024-10-18 152557" src="https://github.com/user-attachments/assets/8e8b18e3-a2ca-47e9-ba7e-de3017b6bff2">

Query:
```sql
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
```


2. **Rank all things**
   
 <img width="333" alt="{597952AF-8C60-4454-AA0B-5D59D75756A7}" src="https://github.com/user-attachments/assets/c08e986f-782b-4312-a366-021ae9974225">

Query:
```sql
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
```
   
