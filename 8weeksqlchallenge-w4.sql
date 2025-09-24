-- A. Customer Nodes Exploration
-- 1. How many unique nodes are there on the Data Bank system?
SELECT
    COUNT(DISTINCT node_id)
FROM
    customer_nodes;

-- 2. What is the number of nodes per region?
SELECT
    COUNT(DISTINCT node_id) AS node_per_region
FROM
    customer_nodes
GROUP BY
    region_id;

-- 3. How many customers are allocated to each region?
SELECT
    COUNT(customer_id) AS customer_region
FROM
    customer_nodes
GROUP BY
    region_id;

-- 4. How many days on average are customers reallocated to a different node?
SELECT
    customer_id,
    AVG(end_date - start_date) AS avg_days_per_node -- AVG(EXTRACT (DAY FROM AGE(end_date, start_date))) AS avg_days_per_node
FROM
    customer_nodes
WHERE
    EXTRACT(
        YEAR
        FROM
            end_date
    ) != 9999
GROUP BY
    customer_id
ORDER BY
    customer_id
SELECT
    AVG(end_date - start_date) AS avg_days_per_node
FROM
    customer_nodes
WHERE
    end_date != '9999-12-31';

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
SELECT
    regions.region_name,
    PERCENTILE_CONT(0.5) WITHIN GROUP(
        ORDER BY
            end_date - start_date
    ),
    PERCENTILE_CONT(0.80) WITHIN GROUP(
        ORDER BY
            end_date - start_date
    ),
    PERCENTILE_CONT(0.95) WITHIN GROUP(
        ORDER BY
            end_date - start_date
    )
FROM
    customer_nodes
    JOIN regions ON regions.region_id = customer_nodes.region_id
WHERE
    EXTRACT(
        YEAR
        FROM
            end_date
    ) != 9999
GROUP BY
    regions.region_name -- B. Customer Transactions
    -- 1. What is the unique count and total amount for each transaction type?
SELECT
    txn_type,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(txn_amount) as total_amount
FROM
    customer_transactions ctr
GROUP BY
    txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?
SELECT
    AVG(haha.total_deposit) AS avg_total_deposit_amount_per_customer,
    AVG(haha.deposit_count) AS avg_deposit_count_per_customer
FROM
    (
        SELECT
            customer_id,
            SUM(txn_amount) AS total_deposit,
            COUNT(*) AS deposit_count
        FROM
            customer_transactions ctr
        WHERE
            txn_type = 'deposit'
        GROUP BY
            customer_id
    ) AS haha;

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
SELECT cus_deposit.myear,
       cus_deposit.mmonth,
       COUNT(DISTINCT cus_deposit.customer_id) AS total_cus
FROM
  (SELECT customer_id,
          COUNT(*) AS deposit_count,
          EXTRACT(YEAR
                  FROM txn_date) AS myear,
          EXTRACT(MONTH
                  FROM txn_date) AS mmonth
   FROM customer_transactions ctr
   WHERE txn_type = 'deposit'
   GROUP BY customer_id,
            EXTRACT(YEAR
                    FROM txn_date),
            EXTRACT(MONTH
                    FROM txn_date)
   HAVING COUNT(*) >= 2) AS cus_deposit
JOIN
  (SELECT customer_id,
          EXTRACT(YEAR
                  FROM txn_date) AS myear,
          EXTRACT(MONTH
                  FROM txn_date) AS mmonth
   FROM customer_transactions ctr
   WHERE txn_type IN ('purchase',
                      'withdrawal')
   GROUP BY customer_id,
            EXTRACT(YEAR
                    FROM txn_date),
            EXTRACT(MONTH
                    FROM txn_date)
   HAVING COUNT(*) >= 1) AS cus_pur_with ON cus_deposit.customer_id = cus_pur_with.customer_id
AND cus_deposit.myear = cus_pur_with.myear
AND cus_deposit.mmonth = cus_pur_with.mmonth
GROUP BY cus_deposit.myear,
         cus_deposit.mmonth;
-- 4. What is the closing balance for each customer at the end of the month?
WITH adjusted_transactions AS (
  SELECT
    customer_id,
    DATE_TRUNC('month', txn_date) AS by_month,
    CASE
      WHEN txn_type = 'deposit' THEN txn_amount
      ELSE -txn_amount
    END AS adjusted_amount
  FROM customer_transactions
  )
  , monthly_balance AS (
  	SELECT customer_id, by_month,
    SUM(adjusted_amount) AS monthly_net_change
    FROM adjusted_transactions
    GROUP BY customer_id, by_month
  )
--  Cách viết đầy đủ
  , closing_balance AS (
  	SELECT customer_id, by_month,
    SUM(monthly_net_change) OVER(
      PARTITION BY customer_id 
      ORDER BY by_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
    FROM monthly_balance
  )
--   Cách viết ngắn gọn
--   ,closing_balance AS (
--   SELECT
--     customer_id,
--     by_month,
--     SUM(monthly_net_change) OVER (
--       PARTITION BY customer_id
--       ORDER BY by_month
--     ) AS closing_balance
--   FROM monthly_balance
-- )
SELECT *
FROM closing_balance
ORDER BY customer_id, by_month

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?
WITH monthly_transaction AS
  (SELECT customer_id,
          DATE_TRUNC('month', txn_date) AS months,
          SUM(CASE
                  WHEN txn_type = 'deposit' THEN txn_amount
                  ELSE -txn_amount
              END) AS monthly_change
   FROM customer_transactions
   GROUP BY customer_id,
            DATE_TRUNC('month', txn_date)),
     running_balance AS
  (SELECT customer_id,
          months,
          SUM(monthly_change) OVER (PARTITION BY customer_id
                                    ORDER BY months ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
   FROM monthly_transaction),
     balance_change AS
  (SELECT customer_id,
          months,
          closing_balance,
          LAG(closing_balance) OVER (PARTITION BY customer_id
                                     ORDER BY months) AS prev_balance
   FROM running_balance)
SELECT ROUND(100.0 * COUNT(*) FILTER (
    WHERE closing_balance > prev_balance * 1.05) / COUNT(*), 2) AS percent_increased
FROM balance_change
WHERE prev_balance IS NOT NULL;
-- C. Data Allocation Challenge
-- To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:
WITH run_balance AS(
    SELECT customer_id, txn_date, txn_type, txn_amount,
    SUM(
        CASE
            WHEN txn_type = 'deposit' THEN txn_amount
            ELSE -txn_amount
        END
    ) OVER (
        PARTITION BY customer_id ORDER BY txn_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS balance
    FROM customer_transactions
)
,monthly_closing AS(
    SELECT customer_id, DATE_TRUNC('month', txn_date) AS months,
    MAX(balance) AS closing_balance
    FROM run_balance
    GROUP BY customer_id, DATE_TRUNC('month', txn_date)
    ORDER BY customer_id
)
, rolling_avg AS (
    SELECT customer_id, txn_date,
    ROUND(
        AVG(balance) OVER (PARTITION BY customer_id ORDER BY txn_date
        RANGE BETWEEN INTERVAL '30 days' PRECEDING AND CURRENT ROW
    ),2)AS avg_30_day_balance
    FROM run_balance
)
-- 1. Option 1: data is allocated based off the amount of money at the end of the previous month
SELECT months, SUM(closing_balance) AS total_data_allocated
FROM monthly_closing
GROUP BY months;
-- 2. Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
SELECT DATE_TRUNC('month', txn_date) AS months,
       SUM(avg_30_day_balance) AS total_data_allocated
FROM rolling_avg
GROUP BY DATE_TRUNC('month', txn_date);
-- 3. Option 3: data is updated real-time
SELECT DATE_TRUNC('month', txn_date) AS months,
       SUM(balance) AS total_data_allocated
FROM run_balance
GROUP BY DATE_TRUNC('month', txn_date);
-- For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:
-- running customer balance column that includes the impact each transaction
-- customer balance at the end of each month
-- minimum, average and maximum values of the running balance for each customer
-- Using all of the data available - how much data would have been required for each option on a monthly basis?

-- D. Extra Challenge
-- Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.
-- If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?
-- Special notes:
-- Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!
WITH transaction_adjustment AS (
  SELECT
    customer_id,
    txn_date,
    CASE
      WHEN txn_type = 'deposit' THEN txn_amount
      ELSE -txn_amount
    END AS adjusted_amount
  FROM customer_transactions
),
daily_balance AS (
  SELECT
    customer_id,
    txn_date,
    SUM(adjusted_amount) OVER (
      PARTITION BY customer_id
      ORDER BY txn_date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS balance
  FROM transaction_adjustment
),
daily_interest AS (
  SELECT
    customer_id,
    txn_date,
    balance,
    ROUND(balance * 0.06 / 365, 2) AS daily_data_growth
  FROM daily_balance
)
SELECT
  DATE_TRUNC('month', txn_date) AS month,
  SUM(daily_data_growth) AS total_data_allocated
FROM daily_interest
GROUP BY DATE_TRUNC('month', txn_date)
ORDER BY month;

-- Extension Request
-- The Data Bank team wants you to use the outputs generated from the above sections to create a quick Powerpoint presentation which will be used as marketing materials for both external investors who might want to buy Data Bank shares and new prospective customers who might want to bank with Data Bank.

-- Using the outputs generated from the customer node questions, generate a few headline insights which Data Bank might use to market it’s world-leading security features to potential investors and customers.

-- With the transaction analysis - prepare a 1 page presentation slide which contains all the relevant information about the various options for the data provisioning so the Data Bank management team can make an informed decision.

