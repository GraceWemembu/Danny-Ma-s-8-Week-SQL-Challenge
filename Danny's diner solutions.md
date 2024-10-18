1. What is the total amount each customer spent at the restaurant?
   ```sql
   SELECT customer_id, SUM(price) AS amount_spent 
   FROM sales 
   JOIN menu 
   ON menu.product_id = sales.product_id
   GROUP BY customer_id;

<img width="137" alt="1" src="https://github.com/user-attachments/assets/386510ef-135f-4adf-8866-c3c7a1a9d157">
