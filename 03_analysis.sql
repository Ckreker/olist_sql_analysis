-- 1. Топ-10 категорий товаров по количеству продаж
SELECT 
    p.product_category_name,
    COUNT(oi.order_id) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC
LIMIT 10;

-- 2. Количество заказов по статусам
SELECT 
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC

-- 3. Топ-10 продавцов по выручке с указанием их городов
SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state,
    SUM(oi.price + oi.freight_value) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;

-- 4. Среднее время доставки по категориям (в днях)
WITH delivery_times AS (
    SELECT 
        p.product_category_name,
        EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) AS delivery_days
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
)
SELECT 
    product_category_name,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    COUNT(*) AS sample_size
FROM delivery_times
GROUP BY product_category_name
HAVING COUNT(*) >= 10
ORDER BY avg_delivery_days ASC;

-- 5. Клиенты, которые делают повторные покупки
WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.price + oi.freight_value) AS total_spent,
        MIN(o.order_purchase_timestamp) AS first_order,
        MAX(o.order_purchase_timestamp) AS last_order
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'New'
        WHEN order_count BETWEEN 2 AND 3 THEN 'Regular'
        ELSE 'VIP'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spent), 2) AS avg_ltv
FROM customer_orders
GROUP BY customer_segment;

-- 6. Самые популярны способы оплаты
SELECT 
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_value), 2) AS total_amount,
    ROUND(AVG(payment_value), 2) AS avg_payment
FROM order_payments
GROUP BY payment_type
ORDER BY total_amount DESC;

-- 7. Сезонность. Продажи по месяцам
SELECT 
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY month;

--8. RFM-Анализ
WITH customer_metrics AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_purchase,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price + oi.freight_value) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT 
        customer_unique_id,
        NTILE(4) OVER (ORDER BY last_purchase DESC) AS recency_score,
        NTILE(4) OVER (ORDER BY frequency DESC) AS frequency_score,
        NTILE(4) OVER (ORDER BY monetary DESC) AS monetary_score
    FROM customer_metrics
)
SELECT 
    customer_unique_id,
    recency_score + frequency_score + monetary_score AS total_score,
    CASE 
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'VIP'
        WHEN recency_score >= 3 AND frequency_score >= 2 THEN 'Loyal'
        WHEN recency_score >= 2 AND frequency_score >= 2 THEN 'Regular'
        ELSE 'At Risk'
    END AS segment
FROM rfm_scores
ORDER BY total_score DESC
LIMIT 20;
