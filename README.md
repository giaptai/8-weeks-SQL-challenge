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
## Week 3 - Case Study #3: Foodie-Fi  
### Tóm tắt kiến thức SQL đã áp dụng
Dưới đây là các nhóm kiến thức SQL mà tôi đã vận dụng trong các câu truy vấn:

### 1. **CTE (Common Table Expression - WITH)**
- Dùng `WITH ... AS (...)` để chia nhỏ truy vấn thành nhiều bước, dễ đọc và tái sử dụng.
- Ví dụ: `WITH hehe AS (...) SELECT * FROM hehe;`

---

### 2. **Aggregate Functions**
- `COUNT(*)`, `COUNT(DISTINCT ...)`, `AVG()`, `ROUND()`, `MIN()`, `MAX()`.
- Tính toán tổng số khách hàng, tỉ lệ %, trung bình số ngày, v.v.

---

### 3. **GROUP BY & HAVING**
- `GROUP BY` để gom nhóm theo tháng, theo khách hàng, theo gói cước.
- `HAVING` để lọc nhóm (ví dụ: khách hàng có **COUNT(*) = 2**).

---

### 4. **Date/Time Functions**
- `EXTRACT(YEAR FROM start_date)`, `EXTRACT(MONTH FROM start_date)` để lấy năm, tháng.
- `DATE_TRUNC('MONTH', start_date)` để cắt về đầu tháng.
- `generate_series(start_date, end_date, interval '1 month')` để sinh chuỗi ngày/tháng.
- Phép toán ngày: `first_annual_date - join_date`.

---

### 5. **Window Functions**
- `LAG()` để lấy giá trị ở bản ghi trước (theo khách hàng).
- `LEAD()` để lấy giá trị ở bản ghi sau.
- `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)` để đánh số thứ tự.
- Ứng dụng trong việc tìm **plan trước đó**, **xác định nâng/hạ cấp**, hoặc **thanh toán định kỳ**.

---

### 6. **Subquery & Derived Table**
- Subquery trong `FROM (...) AS alias`.
- Subquery trong `JOIN (...) AS alias`.
- Subquery để tính `total_customer`, `total_count`.

---

### 7. **JOINs**
- `JOIN` để nối bảng `plans` và `subscriptions`.
- `LEFT JOIN` với bảng `churn_dates` để xử lý khách hàng rời bỏ.
- `JOIN ... ON TRUE` để nối chéo khi cần.

---

### 8. **CASE WHEN**
- Dùng `CASE` để phân loại bucket ngày (`0-30`, `31-60`, …).
- Tính toán số tiền upgrade/annual dựa trên `plan_id`.

---

### 9. **DISTINCT & DISTINCT ON**
- `DISTINCT` để loại bỏ trùng khách hàng.
- `DISTINCT ON (customer_id)` để lấy bản ghi **mới nhất** theo khách hàng.

---

### 10. **Union & Data Combination**
- `UNION ALL` để gộp dữ liệu từ nhiều nguồn thanh toán (monthly, upgrade, annual).

---

### 11. **Percentage & Ratio Calculation**
- Tính % khách hàng chọn 1 plan so với tổng (`COUNT / total * 100`).
- Dùng `ROUND(..., 1)` hoặc `ROUND(..., 2)` để định dạng kết quả.

---

### 12. **Churn, Upgrade, Downgrade Logic**
- **Downgrade**: khách chuyển từ gói cao xuống gói thấp (VD: từ 2 xuống 1).
- **Upgrade**: khách nâng cấp gói trong cùng tháng.
- **Churn**: khách rời bỏ tại gói cuối (`plan_id = 4`).

---

### ✅ Kết luận
Các truy vấn đã bao quát nhiều kiến thức SQL quan trọng:
- **CTE**
- **Aggregate + Grouping**
- **Window Functions**
- **Date/Time Functions**
- **JOIN + Subquery**
- **CASE WHEN + Bucketing**
- **Distinct / Distinct On**
- **Union**
- **Phân tích churn, upgrade, downgrade**

=> Đây là bộ kỹ năng SQL nâng cao, phù hợp cho phân tích dữ liệu khách hàng và hành vi subscription.

---
# Week 3 - Case Study #3 - Foodie-Fi - phần này dành cho SECTION C (khó vcl) 
# 🧠 Tổng thể mục tiêu:

Bạn cần tạo một bảng **thanh toán của từng khách hàng trong năm 2020**, bao gồm:

* Các khoản **thanh toán định kỳ hàng tháng**.
* Các khoản **nâng cấp** (và chỉ trả phần chênh lệch).
* Các khoản **thanh toán hàng năm** (pro annual).
* **Không tính thanh toán sau khi khách đã churn.**
* Cuối cùng, bạn **đánh số thứ tự** từng lần thanh toán cho mỗi khách hàng.

---

# 📘 Chi tiết các phần:

## ✅ `plan_timeline`

```sql
WITH plan_timeline AS (
  SELECT customer_id,
         sub.plan_id,
         p.plan_name,
         LAG(sub.plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_plan,
         LAG(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_start_date,
         sub.start_date,
         COALESCE(LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date), DATE '2020-12-31') AS end_date,
         p.price
  FROM subscriptions sub
  JOIN plans p ON p.plan_id = sub.plan_id
  WHERE EXTRACT(YEAR FROM sub.start_date) = 2020
),
```

### 🎯 Mục đích:

Tạo ra "dòng thời gian đăng ký" của từng khách hàng trong năm 2020, gồm:

* Kế hoạch hiện tại và kế hoạch trước đó (`prev_plan`)
* Ngày bắt đầu và ngày kết thúc của mỗi gói
* Giá gói

### 💬 Giải thích:

* `LAG()` giúp lấy gói **trước đó** (để kiểm tra có phải nâng cấp không).
* `LEAD()` giúp lấy ngày **bắt đầu kế tiếp** để tính ngày **kết thúc** của gói hiện tại.
* `COALESCE(..., '2020-12-31')`: Nếu không có gói tiếp theo → giả sử kết thúc vào cuối năm.

### 🧠 Tại sao cần?

Để xác định:

* Khi nào gói bắt đầu/kết thúc.
* Khi nào người dùng nâng cấp.
* Tính toán các khoản thanh toán đúng khoảng thời gian.

---

## ✅ `churn_dates`

```sql
churn_dates AS (
  SELECT customer_id, start_date AS churn_date
  FROM plan_timeline
  WHERE plan_id = 4
),
```

### 🎯 Mục đích:

Xác định **ngày khách hàng churn (hủy đăng ký)**.

* `plan_id = 4` là gói churn.
* Dùng để **loại bỏ** các khoản thanh toán **sau khi churn**.

---

## ✅ `monthly_payments`

```sql
monthly_payments AS (
  SELECT 
    b.customer_id,
    b.plan_id,
    b.plan_name,
    gs.payment_date,
    b.price AS amount,
    ROW_NUMBER() OVER (PARTITION BY b.customer_id ORDER BY gs.payment_date) AS payment_order
  FROM plan_timeline b
  LEFT JOIN churn_dates c ON b.customer_id = c.customer_id
  JOIN generate_series(b.start_date, b.end_date, interval '1 month') AS gs(payment_date)
    ON TRUE
  WHERE b.plan_id IN (1, 2)
    AND gs.payment_date <= '2020-12-31'
    AND (c.churn_date IS NULL OR gs.payment_date < c.churn_date)
),
```

### 🎯 Mục đích:

Tạo ra **các khoản thanh toán hàng tháng** dựa trên khoảng thời gian sử dụng gói **basic** hoặc **pro monthly**.

### 💬 Giải thích:

* Dùng `generate_series()` để tạo **các ngày thanh toán hàng tháng** giữa `start_date` và `end_date`.
* Không tạo thanh toán sau `churn_date`.
* `ROW_NUMBER()` ban đầu dùng để đánh số lần thanh toán — nhưng giờ ta đã thay bằng cách khác ở cuối rồi.

---

## ✅ `upgrade_payments`

```sql
upgrade_payments AS (
  SELECT 
    b.customer_id,
    b.plan_id,
    b.plan_name,
    b.start_date AS payment_date,
    CASE 
      WHEN b.plan_id = 2 THEN 19.90 - 9.90
      WHEN b.plan_id = 3 THEN 199.00 - 9.90
    END AS amount,
    CAST(NULL AS INTEGER) AS payment_order
  FROM plan_timeline b
  LEFT JOIN churn_dates c ON b.customer_id = c.customer_id
  WHERE b.prev_plan = 1
    AND b.plan_id IN (2, 3)
    AND EXTRACT(YEAR FROM b.start_date) = EXTRACT(YEAR FROM b.prev_start_date)
    AND EXTRACT(MONTH FROM b.start_date) = EXTRACT(MONTH FROM b.prev_start_date)
    AND (c.churn_date IS NULL OR b.start_date < c.churn_date)
),
```

### 🎯 Mục đích:

Xử lý trường hợp **nâng cấp trong cùng tháng** từ `basic → pro monthly` hoặc `basic → pro annual`.

### 💬 Giải thích:

* Tính toán chỉ trả phần chênh lệch giá giữa gói mới và cũ.
* Giới hạn nâng cấp trong cùng **tháng và năm** (nếu không thì tính toán sai).
* Ngày thanh toán là ngay khi upgrade bắt đầu.

---

## ✅ `annual_payments`

```sql
annual_payments AS (
  SELECT 
    b.customer_id,
    b.plan_id,
    b.plan_name,
    CASE 
      WHEN b.prev_plan = 0 THEN b.start_date
      WHEN b.prev_plan = 2 THEN b.prev_start_date + interval '1 month'
    END AS payment_date,
    199.00 AS amount,
    CAST(NULL AS INTEGER) AS payment_order
  FROM plan_timeline b
  LEFT JOIN churn_dates c ON b.customer_id = c.customer_id
  WHERE b.prev_plan IN (0, 2)
    AND b.plan_id = 3
    AND (c.churn_date IS NULL OR 
         (CASE 
            WHEN b.prev_plan = 0 THEN b.start_date
            WHEN b.prev_plan = 2 THEN b.prev_start_date + interval '1 month'
          END) < c.churn_date)
)
```

### 🎯 Mục đích:

Tạo dòng thanh toán khi khách hàng chuyển lên **pro annual (gói 3)** từ:

* Trial (gói 0): thanh toán **ngay lập tức**
* Pro monthly (gói 2): thanh toán **cuối chu kỳ hiện tại**

---

## ✅ `all_payments`

```sql
all_payments AS (
  SELECT customer_id, plan_id, plan_name, payment_date, amount
  FROM monthly_payments
  UNION ALL
  SELECT customer_id, plan_id, plan_name, payment_date, amount
  FROM upgrade_payments
  UNION ALL
  SELECT customer_id, plan_id, plan_name, payment_date, amount
  FROM annual_payments
)
```

### 🎯 Mục đích:

Gộp tất cả các khoản thanh toán lại thành **một bảng duy nhất** để xử lý tiếp.

---

## ✅ Truy vấn cuối cùng

```sql
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM all_payments
ORDER BY customer_id, payment_date;
```

### 🎯 Mục đích:

* Tạo `payment_order` cho toàn bộ các thanh toán của mỗi khách hàng — từ lần đầu đến lần cuối.
* Sắp xếp theo `customer_id` và ngày thanh toán.

---

# ✅ Tổng kết CTE và tác dụng

| CTE                | Mục đích                                                    |
| ------------------ | ----------------------------------------------------------- |
| `plan_timeline`    | Tạo dòng thời gian đăng ký của từng khách hàng              |
| `churn_dates`      | Xác định ngày khách hàng churn                              |
| `monthly_payments` | Tạo các khoản thanh toán định kỳ hàng tháng                 |
| `upgrade_payments` | Tạo khoản thanh toán upgrade, trừ phần đã trả (basic → pro) |
| `annual_payments`  | Tạo khoản thanh toán upgrade lên pro annual                 |
| `all_payments`     | Gom toàn bộ thanh toán lại                                  |
| `SELECT cuối`      | Đánh số thứ tự thanh toán (`payment_order`) cho từng khách  |

---


