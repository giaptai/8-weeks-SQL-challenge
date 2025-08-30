## Week 1 - Case Study #1: Danny's Diner
  - **Window Function:** RANK(), DENSE_RANK(), ROW_NUMBER() etc
  - **Subquery:** query inside a query, it will go first
  - **Join type:** LEFT, RIGHT, INNER JOIN, SELF
  - **Condition:** CASE...WHEN...THEN...ELSE...END
  - **Aggregate Function:** SUM(), COUNT(), AVG(), MIN(), MAX() etc
  - **Order of query:** FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT
  - **Common Table Expression (CTE):** WITH name_cte AS (query)

## Week 2 - Case Study #2: Pizza Runner

### 1. Data Cleaning and Preparation Skills

- **Using `CASE WHEN`**  
  To handle invalid values such as `'null'` and `NULL`, converting them into empty strings (`''`) for easier processing.

- **Using `REPLACE` and `REGEXP_REPLACE`**  
  To remove non-numeric characters like `'km'`, `'min'`, `'minutes'`, making the data suitable for calculations.

- **Using `CTE` (Common Table Expression)**  
  Creating temporary cleaned tables (`clearned_co`, `clearned_ro`) to make subsequent queries cleaner and more readable.

---

### 2. Data Analysis Skills

#### Aggregate Functions

- `COUNT()` – Count the number of pizzas or orders.
- `SUM()` – Calculate total revenue or total number of pizzas based on conditions.
- `AVG()` – Compute averages (e.g., delivery speed, pickup time).
- `MAX()`, `MIN()` – Find the highest or lowest values.

#### String Manipulation

- `STRING_TO_ARRAY` and `UNNEST` – Convert comma-separated strings into individual rows. This is essential for analyzing pizza ingredients.
- `STRING_AGG` – Combine multiple rows into a single string, useful for listing used ingredients.

#### Date/Time Analysis

- `EXTRACT()` – Extract parts of a timestamp (e.g., hour of the day).
- `TO_CHAR()` – Format date/time into readable strings (e.g., day of the week).

---

### 3. Query Structuring and Joining Techniques

- **Using `JOIN`**  
  - `LEFT JOIN`, `INNER JOIN`: Combine data from multiple tables (`customer_orders`, `runner_orders`, `pizza_names`, etc.) to answer complex questions.

- **Using Subqueries**  
  Nest queries inside others to solve multi-step problems (e.g., count pizzas per order, then find the highest count).

- **Using `CASE WHEN` with `SUM()` or `COUNT()`**  
  A powerful technique to conditionally aggregate data within a single query.

---

> 💡 These are the core SQL skills practiced in Week 2 of the challenge. Mastering them will help you handle real-world data tasks more effectively and professionally.


