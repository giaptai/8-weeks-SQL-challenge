/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- Bonus 1: Join All The Things The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
-- Bonus 2: Rank All The Things Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

-- ANSWERs
-- Question 1: -DONE
SELECT sa.customer_id, SUM(menu.price)
FROM sales sa
LEFT JOIN menu
	ON menu.product_id = sa.product_id
GROUP BY sa.customer_id
ORDER BY sa.customer_id

--Question 2 - DONE
SELECT sa.customer_id, COUNT(DISTINCT sa.order_date) as TheDay
FROM sales sa
GROUP BY sa.customer_id;
ORDER BY sa.customer_id

--Question 3 - DONE
SELECT ranked.customer_id, ranked.product_name
FROM (
	SELECT sa.customer_id, menu.product_name,
		DENSE_RANK() OVER (PARTITION BY sa.customer_id ORDER BY sa.order_date) AS rankw
	FROM sales sa
	INNER JOIN menu
		ON sa.product_id = menu.product_id
) as ranked
WHERE rankw = 1
GROUP BY ranked.customer_id, ranked.product_name



--Question 4 - DONE
SELECT menu.product_id, menu.product_name, COUNT(sa.product_id)
FROM sales sa
INNER JOIN menu
	ON sa.product_id = menu.product_id
GROUP BY menu.product_id, menu.product_name
ORDER BY COUNT(sa.product_id) DESC 
LIMIT 1

--Question 5 - DONE
SELECT r.customer_id, r.product_name, r.order_count
	FROM (
		SELECT sa.customer_id, menu.product_name, COUNT(sa.product_id) AS order_count,
		DENSE_RANK() OVER (PARTITION BY sa.customer_id ORDER BY COUNT(sa.product_id) DESC) as rankw
		FROM sales sa
		INNER JOIN menu
			ON sa.product_id = menu.product_id
      	GROUP BY sa.customer_id, menu.product_name
	) AS r
WHERE r.rankw = 1

-- Question 6 - DONE
SELECT  he.customer_id,   he.product_name
FROM (
  SELECT sa.customer_id, menu.product_name,
  ROW_NUMBER() OVER 
  	(PARTITION BY sa.customer_id 
     ORDER BY sa.order_date ASC) as da
  FROM sales sa
  INNER JOIN members mem
      ON sa.customer_id = mem.customer_id
      AND mem.join_date < sa.order_date -- < if different day, <= same day
  INNER JOIN menu
      ON menu.product_id = sa.product_id
) as he
 WHERE he.da = 1
 ORDER BY he.customer_id

-- Question 7 - DONE
SELECT minhthu.customer_id, minhthu.product_name
FROM (
	SELECT sa.customer_id, menu.product_name,
    ROW_NUMBER() OVER (PARTITION BY sa.customer_id
                      ORDER BY sa.order_date DESC) as last_order
  	FROM sales sa
  	INNER JOIN menu 
  		ON sa.product_id = menu.product_id
  	INNER JOIN members mem
  		ON sa.customer_id = mem.customer_id
        AND mem.join_date > sa.order_date
) AS minhthu
WHERE minhthu.last_order = 1
GROUP BY minhthu.customer_id, minhthu.product_name

-- Question 8 - DONE
SELECT sa.customer_id, COUNT(sa.product_id), SUM(menu.price)
FROM sales sa 
INNER JOIN members mem
	ON sa.customer_id = mem.customer_id
INNER JOIN menu
	ON sa.product_id = menu.product_id
WHERE sa.order_date < mem.join_date
GROUP BY sa.customer_id

-- Question 9 - DONE
SELECT sa.customer_id, 
	SUM(
    	CASE 
      		WHEN menu.product_name = 'sushi'  THEN menu.price * 20
      		ELSE menu.price * 10
      	END
    ) as points
FROM sales sa
INNER JOIN menu
	ON sa.product_id = menu.product_id
GROUP BY sa.customer_id
ORDER BY sa.customer_id

-- Question 10
SELECT sa.customer_id, SUM(menu.price * 10 * 2)
FROM sales sa
INNER JOIN members mem
	ON sa.customer_id = mem.customer_id
	AND sa.order_date >= mem.join_date
    AND sa.order_date <= '2021-01-31'
 INNER JOIN menu
 	ON menu.product_id = sa.product_id
 GROUP BY sa.customer_id
ORDER BY sa.customer_id

-- Bonus 1 - DONE
SELECT sa.customer_id, sa.order_date, menu.product_name, menu.price as price, 
	CASE
    	WHEN mem.join_date <= sa.order_date THEN 'Y'
        ELSE 'N'
    END
FROM sales sa
LEFT JOIN menu
	ON menu.product_id = sa.product_id
LEFT JOIN members mem
	ON mem.customer_id = sa.customer_id
ORDER BY sa.customer_id, sa.order_date, menu.product_name

-- Bonus 2:
SELECT sa.customer_id, sa.order_date, menu.product_name, menu.price as price,
CASE
	WHEN mem.join_date <=
FROM sales sa
LEFT JOIN menu
	sa.product_id = menu.product_id
LEFT JOIN members mem
	mem.customer_id = sa.customer_id
ORDER BY



 

 




