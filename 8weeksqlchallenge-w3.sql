-- A. Customer Journey
-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
-- Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
WITH hehe AS (
SELECT EXTRACT(MONTH FROM sub.start_date),
  COUNT(DISTINCT sub.customer_id)
FROM subscriptions sub
GROUP BY EXTRACT(MONTH FROM sub.start_date)
  )
SELECT * FROM hehe;  
- All customers experienced the Trial Plan during onboarding;
- 546 customers subscribed to the Basic Monthly Plan;
- 539 customers subscribed to the Pro Monthly Plan;
- 258 customers subscribed to the Pro Annual Plan;
- 307 customers subscribed to the Churn Plan;
- 1000 customers had a start date in 2020, while 188 customers started in 2021;
- The months with the highest number of customer start dates were January (Month 1) and October (Month 10);

-- B. Data Analysis Questions
-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id)
FROM subscriptions sub;
-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT COUNT(sub.customer_id), DATE_TRUNC('MONTH', sub.start_date) AS month_start
FROM subscriptions sub
WHERE sub.plan_id = 0
GROUP BY month_start
ORDER BY month_start;
-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT p.plan_name, COUNT(*)
FROM (
SELECT * 
FROM subscriptions sub
WHERE EXTRACT(YEAR FROM sub.start_date) > 2020
  ) AS after20
  JOIN plans p
  ON after20.plan_id = p.plan_id
  GROUP BY p.plan_name
-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(sub.customer_id), 
ROUND(CAST(COUNT(sub.customer_id) AS NUMERIC) / sj.total_customer * 100, 1)
FROM subscriptions sub
JOIN (
  SELECT 
  	COUNT(DISTINCT customer_id) AS total_customer 
  	FROM subscriptions
) AS sj ON TRUE
WHERE sub.plan_id = 4
GROUP BY sj.total_customer
-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
SELECT COUNT(total_customer.customer_id),
ROUND(
  COUNT(total_customer.customer_id)::NUMERIC / hehe.hmm * 100
)
FROM(
  SELECT customer_id
  FROM subscriptions
  GROUP BY customer_id
  HAVING COUNT(*) = 2 
  AND MAX (plan_id) = 4 AND MIN(plan_id) = 0
) AS total_customer
JOIN (
	SELECT COUNT(DISTINCT customer_id) AS hmm FROM subscriptions
) AS hehe ON TRUE;

-- 6. What is the number and percentage of customer plans after their initial free trial?
SELECT COUNT(*) AS so_luong_goi_sau_trial,
ROUND(
	COUNT(*)::NUMERIC/all_plan.count * 100, 2
)
FROM subscriptions
JOIN (SELECT COUNT(*) FROM subscriptions) AS all_plan 
	ON TRUE
WHERE plan_id IN (1,2,3,4)
GROUP BY all_plan.count;
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
SELECT 
    p.plan_name,
    COUNT(*) AS total_customer,
    ROUND(COUNT(*)::NUMERIC / total.total_count * 100, 2) AS percentage
FROM (
    SELECT DISTINCT ON (customer_id)
        customer_id,
        plan_id
    FROM subscriptions
    WHERE start_date <= '2020-12-31'
    ORDER BY customer_id, start_date DESC
) AS latest_sub
JOIN plans p ON latest_sub.plan_id = p.plan_id
JOIN (
    SELECT COUNT(*) AS total_count
    FROM (
        SELECT DISTINCT ON (customer_id)
            customer_id
        FROM subscriptions
        WHERE start_date <= '2020-12-31'
        ORDER BY customer_id, start_date DESC
    ) AS temp
) AS total ON TRUE
GROUP BY p.plan_name, total.total_count
ORDER BY total_customer DESC;
-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id)
FROM (
  SELECT customer_id,
         plan_id,
         start_date,
         LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS previous_plan
  FROM subscriptions
) AS sub_with_lag
WHERE plan_id = 3
  AND EXTRACT(YEAR FROM start_date) = 2020
  AND previous_plan IN (0, 1, 2);
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
SELECT 
    ROUND(AVG(diff.days_between), 3) AS avg_days_to_annual
FROM (
    SELECT 
        jd.customer_id, 
        ad.first_annual_date - jd.join_date AS days_between
    FROM (
        -- Ngày khách hàng join lần đầu
        SELECT 
            customer_id, 
            MIN(start_date) AS join_date
        FROM subscriptions 
        GROUP BY customer_id
    ) AS jd
    JOIN (
        -- Ngày khách hàng dùng annual lần đầu
        SELECT 
            customer_id, 
            MIN(start_date) AS first_annual_date
        FROM subscriptions
        WHERE plan_id = 3
        GROUP BY customer_id
    ) AS ad
    ON jd.customer_id = ad.customer_id
) AS diff;
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH diff_days  AS (
 SELECT 
        jd.customer_id, 
        ad.first_annual_date - jd.join_date AS days_between
    FROM (
        -- Ngày khách hàng join lần đầu
        SELECT 
            customer_id, 
            MIN(start_date) AS join_date
        FROM subscriptions 
        GROUP BY customer_id
    ) AS jd
    JOIN (
        -- Ngày khách hàng dùng annual lần đầu
        SELECT 
            customer_id, 
            MIN(start_date) AS first_annual_date
        FROM subscriptions
        WHERE plan_id = 3
        GROUP BY customer_id
    ) AS ad
    ON jd.customer_id = ad.customer_id
  ), bucketed AS (
    SELECT
        customer_id,
        days_between,
        FLOOR((days_between - 1) / 30) AS bucket_index
    FROM diff_days
),
labeled AS (
    SELECT
        customer_id,
        days_between,
        bucket_index,
        CASE 
            WHEN bucket_index * 30 + 30 >= 120 
                THEN CONCAT('>=', 120, ' days')
            ELSE CONCAT(bucket_index * 30 + 1, '-', (bucket_index + 1) * 30, ' days')
        END AS bucket_label
    FROM bucketed
)
  SELECT
    bucket_label,
    COUNT(*) AS customer_count,
    ROUND(AVG(days_between), 2) AS avg_days
FROM labeled
GROUP BY bucket_label
ORDER BY MIN(bucket_index);
-- CÁCH 2 LỎ:
  SELECT
    CASE
        WHEN days_between <= 30 THEN '0-30 days'
        WHEN days_between <= 60 THEN '31-60 days'
        WHEN days_between <= 90 THEN '61-90 days'
        WHEN days_between <= 120 THEN '91-120 days'
        ELSE '120+ days'
    END AS day_range,
    COUNT(*) AS customer_count
FROM diff_days
GROUP BY 1; -- GROUP theo cột đầu tiên

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
SELECT COUNT(DISTINCT hehe.customer_id) AS num_customers_downgraded
FROM
  (SELECT customer_id,
          start_date,
          plan_id,
          LAG (plan_id) OVER (PARTITION BY customer_id
                              ORDER BY start_date) AS prev_plan_id
   FROM subscriptions) AS hehe
WHERE hehe.plan_id =1
  AND hehe.prev_plan_id = 2
  AND EXTRACT(YEAR
              FROM hehe.start_date) = 2020
-- C. Challenge Payment Question
-- The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
-- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
-- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
-- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
-- once a customer churns they will no longer make payments
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
churn_dates AS (
  SELECT customer_id, start_date AS churn_date
  FROM plan_timeline
  WHERE plan_id = 4
),
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
,all_payments AS (
  SELECT customer_id, plan_id, plan_name, payment_date, amount
  FROM monthly_payments
  UNION ALL
  SELECT customer_id, plan_id, plan_name, payment_date, amount
  FROM upgrade_payments
  UNION ALL
  SELECT customer_id, plan_id, plan_name, payment_date, amount
  FROM annual_payments
)

SELECT *,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM all_payments
ORDER BY customer_id, payment_date;
-- D. Outside The Box Questions
-- The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!
-- 1. How would you calculate the rate of growth for Foodie-Fi?
Tôi sẽ đo tốc độ tăng trưởng của Foodie‑Fi dựa trên sự thay đổi về số lượng khách hàng hoặc 
doanh thu theo từng năm. Trước hết, xác định số khách hàng duy nhất hoặc tổng doanh thu 
của mỗi năm, lấy năm đầu tiên làm mốc gốc để so sánh. Sau đó, theo dõi mức tăng hoặc giảm 
qua từng năm để nhận diện xu hướng phát triển. Cách tiếp cận này có thể áp dụng riêng cho 
từng loại gói dịch vụ để thấy rõ phân khúc nào đang tăng trưởng nhanh nhất, 
từ đó hỗ trợ việc ra quyết định kinh doanh và chiến lược marketing.
-- 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
Với mô hình subscription như Foodie‑Fi, tôi sẽ tập trung theo dõi một nhóm chỉ số cốt lõi để đánh giá sức khỏe và hiệu suất kinh doanh theo thời gian.
Thứ nhất là chỉ số về khách hàng: số lượng khách mới, tỷ lệ giữ chân (retention rate), tỷ lệ rời bỏ (churn rate) và tỷ lệ quay lại sau khi hủy. Đây là những chỉ số trực tiếp phản ánh khả năng thu hút và giữ chân người dùng.
Thứ hai là chỉ số về gói dịch vụ: cơ cấu khách hàng theo từng plan, tỷ lệ nâng cấp/hạ cấp gói, thời gian trung bình để nâng cấp từ trial hoặc basic lên pro/annual. Điều này giúp hiểu rõ hành vi và nhu cầu của từng phân khúc.
Thứ ba là chỉ số tài chính: doanh thu định kỳ hàng tháng (MRR), hàng năm (ARR), doanh thu trung bình trên mỗi khách (ARPU) và giá trị vòng đời khách hàng (CLV). Đây là nền tảng để dự báo và lập kế hoạch tăng trưởng.
Cuối cùng là chỉ số chuyển đổi và mức độ sử dụng: tỷ lệ chuyển đổi từ trial sang trả phí, mức độ sử dụng nội dung, và các hành vi tương tác chính. Những dữ liệu này giúp tối ưu trải nghiệm và cải thiện retention.
Việc theo dõi đồng thời các nhóm chỉ số này sẽ cho Foodie‑Fi một bức tranh toàn diện, từ đó đưa ra quyết định chiến lược dựa trên dữ liệu thay vì cảm tính.
-- 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention
Tôi sẽ tập trung phân tích ba nhóm hành trình và trải nghiệm chính để cải thiện retention:
Hành vi chuyển đổi gói dịch vụ: theo dõi luồng nâng cấp/hạ cấp giữa các plan để hiểu động lực và rào cản khi khách thay đổi gói.
Nguyên nhân churn: phân tích dữ liệu hủy dịch vụ để nhận diện các mẫu hành vi hoặc yếu tố dẫn tới quyết định rời bỏ.
Trải nghiệm với gói basic: đánh giá mức độ hài lòng, tần suất sử dụng và tỷ lệ nâng cấp từ basic để xác định cơ hội cải thiện giá trị gói này. Việc phân tích sâu các hành trình này sẽ giúp xác định điểm rơi của khách hàng, nguyên nhân mất khách và cơ hội tối ưu sản phẩm/dịch vụ để giữ chân họ lâu hơn.
-- 4 .If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
Tôi sẽ đề xuất các câu hỏi ngắn gọn, dễ trả lời:
Lý do chính khiến bạn hủy dịch vụ? (nội dung, giá, trải nghiệm, lý do cá nhân…)
Bạn hài lòng mức nào với nội dung và chất lượng dịch vụ?
Có tính năng hoặc nội dung nào bạn mong muốn nhưng chưa có?
Bạn có cân nhắc quay lại trong tương lai không?
Bạn biết đến Foodie‑Fi qua kênh nào? Mục tiêu là thu thập insight để cải thiện sản phẩm và chiến lược giữ chân.
-- 5 .What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?
Để giảm tỷ lệ churn, tôi sẽ kết hợp nhiều đòn bẩy kinh doanh nhằm vừa giữ chân khách hàng hiện tại, vừa khuyến khích họ nâng cấp hoặc tiếp tục sử dụng dịch vụ:
Ưu đãi nâng cấp có điều kiện: Ví dụ, nếu khách hàng đã sử dụng dịch vụ liên tục 3 tháng, họ sẽ được giảm 30% cho lần nâng cấp gói tiếp theo. Điều này tạo động lực gắn bó và trải nghiệm các gói cao hơn.
Cải thiện nội dung và cá nhân hóa: Liên tục bổ sung nội dung mới, đa dạng thể loại, và sử dụng dữ liệu hành vi để đề xuất nội dung phù hợp từng người.
Ưu đãi giữ chân trước khi churn: Khi phát hiện dấu hiệu khách sắp hủy (ít sử dụng, không tương tác), gửi ưu đãi giảm giá hoặc tặng thêm thời gian sử dụng miễn phí.
Tăng tương tác chủ động: Gửi email hoặc thông báo push với nội dung mới, highlight tính năng mới, hoặc gợi ý nội dung dựa trên lịch sử xem.
Linh hoạt gói dịch vụ: Cho phép tạm dừng (pause) thay vì hủy, để khách quay lại dễ dàng hơn.
Cách đánh giá hiệu quả: Tôi sẽ triển khai thử nghiệm A/B hoặc cohort analysis cho từng biện pháp. Một nhóm khách hàng sẽ nhận ưu đãi/chính sách mới, nhóm còn lại giữ nguyên. Sau đó so sánh các chỉ số như churn rate, retention rate, tỷ lệ nâng cấp, ARPU và CLV. Nếu các chỉ số cải thiện rõ rệt ở nhóm thử nghiệm, có thể mở rộng áp dụng cho toàn bộ khách hàng.