# 1) What is the total amount each customer spent at the restaurant?
use Krishav_dinner;
SELECT 
    s.customer_id, SUM(m.price) AS total_amount
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

# 2) How many days has each customer visited the restaurant?
SELECT 
    customer_id, COUNT(order_date) AS total_days
FROM
    sales
GROUP BY customer_id;

# 3) What was the first item from the menu purchased by each customer?
WITH sale_rankings AS
    (
    SELECT customer_id, order_date, product_name,
    RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS order_rank
    FROM sales s JOIN menu m ON s.product_id = m.product_id
    )
    SELECT customer_id, 
    max(product_name) as first_purchased_item
    FROM sale_rankings
    WHERE order_rank = 1
    GROUP BY customer_id;

# 4) What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
    m.product_name, COUNT(m.product_name) AS purchase_count
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_count DESC
LIMIT 1;

# 5) Which item was the most popular for each customer?

WITH Popularity as (
SELECT
s.customer_id,
m.product_name,
count(m.product_name) as Purchase_count,
row_number() over (partition by s.customer_id order by count(m.product_name) desc) as Popular_item
from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id, m.product_name)

SELECT
    customer_id,
    product_name,
    purchase_count
FROM popularity
WHERE popular_item = 1;

# 6) Which item was purchased first by the customer after they became a member?

WITH first_purchase AS (
SELECT 
s.customer_id,
m.product_name,
s.order_date,
DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS purchase_rank
FROM sales s 
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date >= mem.join_date )

SELECT 
    customer_id, product_name, order_date
FROM
    first_purchase
WHERE
    purchase_rank = 1;

# 7) Which item was purchased just before the customer became a member?
WITH purchase_before_membership AS (
SELECT
s.customer_id,
m.product_name,
s.order_date,
DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS purchase_rank
FROM sales s 
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date <= mem.join_date )

SELECT 
    customer_id, product_name, order_date
FROM
    purchase_before_membership
WHERE
    purchase_rank = 1;

# 8) What is the total items and amount spent for each member before they became a member?
SELECT 
    s.customer_id,
    COUNT(DISTINCT m.product_name) AS total_products,
    SUM(m.price) AS amount_spent
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
        JOIN
    members mem ON s.customer_id = mem.customer_id
WHERE
    s.order_date < mem.join_date
GROUP BY s.customer_id;

  
# 9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
    s.customer_id,
    SUM(CASE
        WHEN m.product_name = 'sushi' THEN 2 * 10
        ELSE 10
    END * m.price) AS total_points
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id; 