-- Очищаем все таблицы (в правильном порядке, чтобы не нарушить связи)
TRUNCATE TABLE order_items CASCADE;
TRUNCATE TABLE order_payments CASCADE;
TRUNCATE TABLE orders CASCADE;
TRUNCATE TABLE products CASCADE;
TRUNCATE TABLE sellers CASCADE;
TRUNCATE TABLE customers CASCADE;
TRUNCATE TABLE geolocation CASCADE;
TRUNCATE TABLE product_category_name_translation CASCADE;

SELECT 
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM orders) AS orders,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM sellers) AS sellers,
    (SELECT COUNT(*) FROM order_items) AS order_items,
    (SELECT COUNT(*) FROM order_payments) AS order_payments,
    (SELECT COUNT(*) FROM geolocation) AS geolocation,
    (SELECT COUNT(*) FROM product_category_name_translation) AS product_category_name_translation;