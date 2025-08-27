-- There is an data issues at customer_orders, fix
SELECT order_id,
    customer_id,
    pizza_id,
    CASE
        WHEN exclusions = 'null' THEN ''
        ELSE exclusions
    END AS exclusions,
    CASE
        WHEN extras = 'null'
        OR extras IS NULL THEN ''
        ELSE extras
    END as extras,
    order_time
FROM customer_orders;
-- There is an data issues at runner_orders, fix
SELECT order_id,
    runner_id,
    CASE
        WHEN pickup_time = 'null' THEN ''
        ELSE pickup_time
    END AS pickup_time,
    CASE
        WHEN distance = 'null' THEN ''
        ELSE distance
    END AS distance,
    CASE
        WHEN duration = 'null' THEN ''
        ELSE duration
    END AS duration,
    CASE
        WHEN cancellation IS NULL THEN ''
        WHEN cancellation = 'null' THEN ''
        ELSE cancellation
    END AS cancellation
FROM runner_orders;
-- or combine use CTE - Common table expression
WITH clearned_co AS (
    SELECT order_id,
        customer_id,
        pizza_id,
        CASE
            WHEN exclusions = 'null' THEN ''
            ELSE exclusions
        END AS exclusions,
        CASE
            WHEN extras = 'null'
            OR extras IS NULL THEN ''
            ELSE extras
        END as extras,
        order_time
    FROM customer_orders
    ORDER BY customer_id
),
clearned_ro AS (
    SELECT order_id,
        runner_id,
        CASE
            WHEN pickup_time = 'null' THEN ''
            ELSE pickup_time
        END AS pickup_time,
        CASE
            WHEN distance = 'null' THEN ''
            WHEN distance LIKE '%km%' THEN REPLACE(distance, 'km', '')
            ELSE distance
        END AS distance,
        CASE
            WHEN duration = 'null' THEN ''
            WHEN duration LIKE '%min%' THEN REGEXP_REPLACE(duration, '||s*(minutes?|mins?|min)', '', 'gi')
            ELSE duration
        END AS duration,
        CASE
            WHEN cancellation IS NULL THEN ''
            WHEN cancellation = 'null' THEN ''
            ELSE cancellation
        END AS cancellation
    FROM runner_orders
) -- A. Pizza Metrics
-- How many pizzas were ordered?
SELECT COUNT(order_id)
FROM customer_orders;
-- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id)
FROM customer_orders;
-- How many successful orders were delivered by each runner?
SELECT COUNT(order_id)
FROM runner_orders;
-- How many of each type of pizza was delivered?
SELECT co.pizza_id,
    COUNT(co.pizza_id) as NUM
FROM runner_orders ro
    LEFT JOIN customer_orders co ON ro.order_id = co.order_id
GROUP BY co.pizza_id -- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT co.customer_id,
    SUM(
        CASE
            WHEN co.pizza_id = 1 THEN 1
            ELSE 0
        END
    ) AS MeatLovers,
    SUM(
        CASE
            WHEN co.pizza_id = 2 THEN 1
            ELSE 0
        END
    ) AS Vegetarian
FROM customer_orders co
GROUP BY co.customer_id
ORDER BY co.customer_id;
-- What was the maximum number of pizzas delivered in a single order?
SELECT MAX(wtf.num_pizza) AS total_pizza
FROM (
        SELECT order_id,
            COUNT(order_id) AS num_pizza
        FROM customer_orders
        GROUP BY order_id
        ORDER BY order_id
    ) AS wtf
    RIGHT JOIN runner_orders ro ON wtf.order_id = ro.order_id;
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT co.customer_id,
    SUM(
        CASE
            WHEN co.exclusions = ''
            AND co.extras = '' THEN 1
            ELSE 0
        END
    ) AS no_change,
    SUM(
        CASE
            WHEN co.exclusions != ''
            OR co.extras != '' THEN 1
            ELSE 0
        END
    ) AS changed
FROM clearned_co co
    INNER JOIN clearned_ro ro ON co.order_id = ro.order_id
    AND ro.cancellation = ''
GROUP BY co.customer_id;
-- How many pizzas were delivered that had both exclusions and extras?
SELECT SUM(
        CASE
            WHEN co.exclusions != ''
            AND co.extras != '' THEN 1
            ELSE 0
        END
    ) as delivery_pizza_change
FROM clearned_co co
    INNER JOIN clearned_ro ro ON co.order_id = ro.order_id
    AND ro.cancellation = '' -- What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(
        HOUR
        FROM co.order_time
    ) AS hours,
    COUNT(co.order_id)
FROM clearned_co co
GROUP BY hours
ORDER BY hours;
-- What was the volume of orders for each day of the week?
-- SELECT TO_CHAR(co.order_time, 'Day') dow FROM clearned_co AS co ORDER BY dow ASC
SELECT TO_CHAR(co.order_time, 'Day') dow,
    COUNT(co.order_id)
FROM clearned_co co
GROUP BY dow
ORDER BY dow ASC;
-- B. Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) có bao nhiêu người giao hàng đã đăng ký trong mỗi khoảng thời gian là 1 tuần
SELECT (
        ((registration_date - DATE '2021-01-01') / 7) + 1
    ) AS weeks,
    COUNT(runner_id) AS num_register
FROM runners
GROUP BY weeks
ORDER BY weeks;
-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id,
    AVG(
        EXTRACT(
            HOUR
            FROM pickup_time::TIMESTAMP
        ) * 60 + EXTRACT(
            MINUTE
            FROM pickup_time::TIMESTAMP
        ) + EXTRACT(
            SECOND
            FROM pickup_time::TIMESTAMP
        ) / 60
    ) AS avg_minute
FROM clearned_ro
WHERE pickup_time != ''
GROUP BY runner_id
ORDER BY runner_id;
-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT co.order_id,
    COUNT(co.pizza_id) as num_pizza,
    CASE
        WHEN ro.pickup_time = '' THEN NULL
        ELSE ro.pickup_time::timestamp - co.order_time::timestamp
    END
FROM clearned_co co
    LEFT JOIN clearned_ro ro ON ro.order_id = co.order_id
GROUP BY co.order_id,
    co.order_time,
    ro.pickup_time
ORDER BY co.order_id;
-- What was the average distance travelled for each customer?
SELECT co.customer_id,
    AVG(
        CASE
            WHEN ro.distance = '' THEN 0
            ELSE ro.distance::numeric
        END
    ) AS avg_distance
FROM clearned_ro ro
    JOIN clearned_co co ON ro.order_id = co.order_id
GROUP BY co.customer_id
ORDER BY co.customer_id -- What was the difference between the longest and shortest delivery times for all orders?
    -- SELECT MAX(ro.pickup_time::timestamp) -MAX(co.order_time::timestamp)
    -- FROM clearned_ro ro
    -- JOIN clearned_co co 
    -- 	ON ro.order_id = co.order_id
    --     AND ro.pickup_time != ''
SELECT MAX(ro.duration),
    MIN(ro.duration),
    MAX(ro.duration::numeric) - MIN(ro.duration::numeric) AS difference
FROM clearned_ro ro
WHERE ro.duration != '' -- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT ro.runner_id,
    AVG(
        ro.distance::numeric / (ro.duration::numeric / 60)
    ) AS avg_speed
FROM clearned_ro ro
WHERE ro.duration != ''
GROUP BY ro.runner_id
ORDER BY ro.runner_id -- What is the successful delivery percentage for each runner?
SELECT ro.runner_id,
    COUNT(cancellation) FILTER (
        WHERE cancellation = ''
    ) AS successful_deliveries,
    COUNT(cancellation) FILTER (
        WHERE cancellation != ''
    ) AS cancelled_orders,
    ROUND(
        COUNT(cancellation) FILTER (
            WHERE cancellation = ''
        )::NUMERIC / COUNT(cancellation)::NUMERIC * 100,
        1
    ) AS success_rate_percent
FROM clearned_ro as ro
GROUP BY ro.runner_id
ORDER BY ro.runner_id;
-- C. Ingredient Optimisation
-- What are the standard ingredients for each pizza?
SELECT pr.pizza_id,
    pr.ingredients_id,
    pt.topping_name
FROM (
        SELECT pizza_id,
            unnest(string_to_array(toppings, ', '))::int AS ingredients_id
        FROM pizza_recipes
    ) AS pr
    JOIN pizza_toppings pt ON pr.ingredients_id = pt.topping_id
GROUP BY pr.pizza_id,
    pr.ingredients_id,
    pt.topping_name
ORDER BY pr.pizza_id;
-- What was the most commonly added extra?
SELECT ingredients.ingredients_id,
    COUNT(ingredients.ingredients_id) AS hehe
FROM(
        SELECT UNNEST(STRING_TO_ARRAY(extras, ', '))::int AS ingredients_id
        FROM clearned_co
    ) AS ingredients
GROUP BY ingredients.ingredients_id
ORDER BY hehe DESC
LIMIT 1;
-- What was the most common exclusion?
SELECT ingredients.ingredients_id,
    COUNT(ingredients.ingredients_id) AS hehe
FROM(
        SELECT UNNEST(STRING_TO_ARRAY(exclusions, ', '))::int AS ingredients_id
        FROM clearned_co
    ) AS ingredients
GROUP BY ingredients.ingredients_id
ORDER BY hehe DESC
LIMIT 1;
-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH EXTRAS AS (
    SELECT co.order_id,
        co.pizza_id,
        co.extras,
        STRING_AGG(DISTINCT pt.topping_name, ', ') AS added_extra
    FROM clearned_co AS co
        LEFT JOIN LATERAL unnest(string_to_array(co.extras, ', ')) AS s(value) ON TRUE
        JOIN pizza_toppings AS pt ON pt.topping_id = s.value::INTEGER
    WHERE LENGTH(s.value) > 0
        AND s.value <> 'null'
    GROUP BY co.order_id,
        co.pizza_id,
        co.extras
),
EXCLUDED AS (
    SELECT co.order_id,
        co.pizza_id,
        co.exclusions,
        STRING_AGG(DISTINCT pt.topping_name, ', ') AS excluded
    FROM clearned_co co
        LEFT JOIN LATERAL UNNEST(STRING_TO_ARRAY(co.exclusions, ', ')) AS S(value) ON TRUE
        INNER JOIN pizza_toppings pt ON pt.topping_id = S.value::INTEGER
    WHERE LENGTH(S.value) > 0
        AND S.value <> 'null'
    GROUP BY co.order_id,
        co.pizza_id,
        co.exclusions
)
SELECT co.order_id,
    CONCAT(
        CASE
            WHEN pn.pizza_name = 'Meatlovers' THEN 'Meat Lovers'
            ELSE pn.pizza_name
        END,
        COALESCE(' - Extra ' || ext.added_extra, ''),
        COALESCE(' - Exclude  ' || exc.excluded, '')
    )
FROM clearned_co co
    LEFT JOIN EXTRAS ext ON ext.order_id = co.order_id
    AND ext.pizza_id = co.pizza_id
    AND ext.extras = co.extras
    LEFT JOIN EXCLUDED exc ON exc.order_id = co.order_id
    AND exc.pizza_id = co.pizza_id
    AND exc.exclusions = co.exclusions
    INNER JOIN pizza_names pn ON pn.pizza_id = co.pizza_id;
-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH EXTRAS AS (
    SELECT co.order_id,
        co.pizza_id,
        co.extras,
        pt.topping_id,
        pt.topping_name as topping_name
    FROM clearned_co AS co
        LEFT JOIN LATERAL unnest(string_to_array(co.extras, ', ')) AS s(value) ON TRUE
        JOIN pizza_toppings AS pt ON pt.topping_id = s.value::INTEGER
    WHERE LENGTH(s.value) > 0
        AND s.value <> 'null'
),
EXCLUDED AS (
    SELECT co.order_id,
        co.pizza_id,
        co.exclusions,
        pt.topping_id,
        pt.topping_name as excluded
    FROM clearned_co co
        LEFT JOIN LATERAL UNNEST(STRING_TO_ARRAY(co.exclusions, ', ')) AS S(value) ON TRUE
        INNER JOIN pizza_toppings pt ON pt.topping_id = S.value::INTEGER
    WHERE LENGTH(S.value) > 0
        AND S.value <> 'null'
),
ORDERS AS (
    SELECT co.order_id,
        co.pizza_id,
        pt.topping_id,
        pt.topping_name
    FROM clearned_co co
        INNER JOIN pizza_recipes pr ON pr.pizza_id = co.pizza_id
        LEFT JOIN LATERAL UNNEST(STRING_TO_ARRAY(pr.toppings, ', ')) AS s(value) ON TRUE
        INNER JOIN pizza_toppings pt ON pt.topping_id = s.value::INTEGER
),
ORDERS_WITH_EXTRAS_AND_EXCLUSIONS AS (
    SELECT o.order_id,
        o.pizza_id,
        o.topping_id,
        o.topping_name
    FROM ORDERS o
        LEFT JOIN EXCLUDED exc ON exc.order_id = o.order_id
        AND exc.pizza_id = o.pizza_id
        AND exc.topping_id = o.topping_id
    WHERE exc.topping_id IS NULL
    UNION ALL
    SELECT order_id,
        pizza_id,
        topping_id,
        topping_name
    FROM EXTRAS
),
INGREDIENT_TOTAL AS (
    SELECT order_id,
        pizza_name,
        topping_name,
        COUNT(topping_id) AS n
    FROM ORDERS_WITH_EXTRAS_AND_EXCLUSIONS o
        INNER JOIN pizza_names pn ON pn.pizza_id = o.pizza_id
    GROUP BY order_id,
        pizza_name,
        topping_name
    ORDER BY order_id,
        pizza_name,
        topping_name
),
SUMMARY AS (
    SELECT order_id,
        pizza_name,
        STRING_AGG(
            CASE
                WHEN n > 1 THEN n || 'x' || topping_name
                ELSE topping_name
            END,
            ', '
            ORDER BY topping_name
        ) AS ingred
    FROM INGREDIENT_TOTAL
    GROUP BY order_id,
        pizza_name
)
SELECT order_id,
    CASE
        WHEN pizza_name = 'Meatlovers' THEN 'Meat Lovers' || ': ' || ingred
        ELSE pizza_name || ': ' || ingred
    END
FROM SUMMARY;
-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first? 
-- Tính tổng số lượng mỗi nguyên liệu được dùng trong các đơn đã giao được sắp xếp theo tần suất thường xuyên nhất
SELECT o.topping_name,
    COUNT(o.topping_id) AS n
FROM ORDERS_WITH_EXTRAS_AND_EXCLUSIONS o
    JOIN clearned_ro ro ON ro.order_id = o.order_id
WHERE ro.cancellation IS NULL
    OR ro.cancellation = 'null'
    OR ro.cancellation = ''
GROUP BY o.topping_name
ORDER BY COUNT(o.topping_id) DESC;