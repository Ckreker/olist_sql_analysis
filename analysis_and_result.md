## 1. Топ-10 категорий товаров по количеству продаж

**Запрос:**
```sql
SELECT 
	p.product_category_name,
	COUNT(oi.order_id) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC
LIMIT 10;
```

**Результат:**
|product_category_name|total_sales|
|---------------------|-----------|
|cama_mesa_banho|11115|
|beleza_saude|9670|
|esporte_lazer|8641|
|moveis_decoracao|8334|
|informatica_acessorios|7827|
|utilidades_domesticas|6964|
|relogios_presentes|5991|
|telefonia|4545|
|ferramentas_jardim|4347|
|automotivo|4235|


## 2. Количество заказов по статусам

**Запрос:**
```sql
SELECT 
	order_status,
	COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;
```

**Результат:**
|order_status|order_count|
|------------|-----------|
|delivered|96478|
|shipped|1107|
|canceled|625|
|unavailable|609|
|invoiced|314|
|processing|301|
|created|5|
|approved|2|


## 3. Топ-10 продавцов по выручке

**Запрос:**
```sql
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
```

**Результат:**
|seller_id|seller_city|seller_state|total_revenue|total_orders|
|---------|-----------|------------|-------------|------------|
|4869f7a5dfa277a7dca6462dcf3b52b2|guariba|SP|247007.06|1124|
|7c67e1448b00f6e969d365cea6b010ab|itaquaquecetuba|SP|237806.69|973|
|4a3ca9315b744ce9f8e9374361493884|ibitinga|SP|231220.43|1772|
|53243585a1d6dc2643021fd1853d8905|lauro de freitas|BA|230797.02|348|
|fa1c13f2614d7b5c4749cbc52fecda94|sumare|SP|200833.50|578|
|da8622b14eb17ae2831f4ac5b9dab84a|piracicaba|SP|184706.78|1311|
|7e93a43ef30c4f03f38b393420bc753a|barueri|SP|171973.55|319|
|1025f0e2d44d7041d6cf58b6550e0bfa|sao paulo|SP|171924.96|910|
|7a67c85e85bb2ce8582c35f2203ad736|sao paulo|SP|160278.52|1145|
|955fee9216a65b617aa5c0531780ce60|sao paulo|SP|156606.48|1261|

## 4. Среднее время доставки по категориям (в днях)

**Запрос:**
```sql
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
```

**Результат:**
|product_category_name|avg_delivery_days|sample_size|
|---------------------|-----------------|-----------|
|artes_e_artesanato|5.29|24|
|la_cuisine|7.07|14|
|livros_importados|7.67|57|
|portateis_cozinha_e_preparadores_de_alimentos|7.79|14|
|artigos_de_festas|8.90|42|
|alimentos|9.10|499|
|construcao_ferramentas_iluminacao|9.25|301|
|portateis_casa_forno_e_cafe|9.40|73|
|sinalizacao_e_seguranca|9.97|197|
|bebidas|10.02|361|
|cine_foto|10.13|70|
|malas_acessorios|10.19|1077|
|livros_tecnicos|10.23|263|
|fraldas_higiene|10.24|37|
|construcao_ferramentas_construcao|10.29|916|
|industria_comercio_e_negocios|10.31|264|
|eletroportateis|10.33|658|
|cds_dvds_musicais|10.36|14|
|alimentos_bebidas|10.45|269|
|utilidades_domesticas|10.46|6795|
|fashion_bolsas_e_acessorios|10.61|1985|
|flores|10.70|33|
|pet_shop|10.76|1924|
|eletrodomesticos|10.87|754|
|artes|10.87|197|
|musica|11.16|38|
|livros_interesse_geral|11.17|536|
|agro_industria_e_comercio|11.22|206|
|brinquedos|11.23|4029|
|perfumaria|11.28|3340|
|fashion_esporte|11.38|29|
|construcao_ferramentas_seguranca|11.43|183|
|construcao_ferramentas_jardim|11.43|232|
|moveis_cozinha_area_de_servico_jantar_e_jardim|11.45|274|
|fashion_roupa_feminina|11.49|45|
|beleza_saude|11.52|9465|
|construcao_ferramentas_ferramentas|11.63|103|
|market_place|11.68|305|
|esporte_lazer|11.69|8430|
|automotivo|11.77|4139|
|climatizacao|11.79|289|
|cool_stuff|11.90|3718|
|bebes|12.06|2982|
|relogios_presentes|12.19|5857|
|telefonia_fixa|12.24|255|
|papelaria|12.28|2466|
||12.31|1537|
|cama_mesa_banho|12.34|10953|
|telefonia|12.38|4430|
|moveis_decoracao|12.40|8160|
|eletronicos|12.42|2729|
|fashion_roupa_masculina|12.47|125|
|instrumentos_musicais|12.50|651|
|dvds_blu_ray|12.51|61|
|tablets_impressao_imagem|12.58|83|
|casa_construcao|12.76|596|
|moveis_quarto|12.76|103|
|informatica_acessorios|12.78|7643|
|audio|12.88|362|
|casa_conforto|13.04|429|
|pcs|13.05|199|
|consoles_games|13.14|1089|
|ferramentas_jardim|13.23|4268|
|fashion_underwear_e_moda_praia|13.28|127|
|moveis_sala|13.29|495|
|eletrodomesticos_2|13.42|231|
|moveis_colchao_e_estofado|13.89|37|
|casa_conforto_2|14.07|30|
|fashion_calcados|14.93|257|
|artigos_de_natal|15.30|150|
|moveis_escritorio|20.39|1668|

## 5. Клиенты, которые делают повторные покупки

**Запрос:**
```sql
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
```

**Результат:**
|customer_segment|customer_count|avg_ltv|
|----------------|--------------|-------|
|New|90557|160.73|
|VIP|47|788.13|
|Regular|2754|300.34|

## 6. Самые популярны способы оплаты

**Запрос:**
```sql
SELECT 
	payment_type,
	COUNT(*) AS payment_count,
	ROUND(SUM(payment_value), 2) AS total_amount,
	ROUND(AVG(payment_value), 2) AS avg_payment
FROM order_payments
GROUP BY payment_type
ORDER BY total_amount DESC;
```

**Результат:**
|payment_type|payment_count|total_amount|avg_payment|
|------------|-------------|------------|-----------|
|credit_card|76795|12542084.19|163.32|
|boleto|19784|2869361.27|145.03|
|voucher|5775|379436.87|65.70|
|debit_card|1529|217989.79|142.57|
|not_defined|3|0.00|0.00|


## 7. Сезонность. Продажи по месяцам

**Запрос:**
```sql
SELECT 
	EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
	COUNT(DISTINCT o.order_id) AS orders_count,
	ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY month;
```

**Результат:**
|month|orders_count|total_revenue|
|-----|------------|-------------|
|1|7819|1205369.83|
|2|8208|1237407.73|
|3|9549|1534929.19|
|4|9101|1523691.33|
|5|10295|1695625.92|
|6|9234|1502028.66|
|7|10031|1594106.36|
|8|10544|1631324.00|
|9|4151|701220.95|
|10|4743|797607.67|
|11|7289|1153364.20|
|12|5514|843097.91|


## 8. RFM-Анализ

**Запрос:**
```sql
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
```

**Результат:**
|customer_unique_id|total_score|segment|
|------------------|-----------|-------|
|066102a90a75eaca71e77248c54d4668|12|VIP|
|b106260fccd09b6f8eb44af569153f45|12|VIP|
|fa9dd2dff8adf12e53678216566bbef8|12|VIP|
|973629b00306fca6592d2726d375dba4|12|VIP|
|bc61ef033404c548cdee700321c246d8|12|VIP|
|f529837b055ca5d7986bd18cfddfe0b9|12|VIP|
|5ab263bf707a0471866a0c7ea0bd8931|12|VIP|
|df28a378659710f7afb9ab93f642db3d|12|VIP|
|1601e40166d1395309093174742df2ff|12|VIP|
|5efc4f7cfd77f13ba84f279a14e10070|12|VIP|
|bea0ea47cda9173d900d25f0ea064b70|12|VIP|
|7c9721a25af8cb3f85c794aecd395f52|12|VIP|
|a296df1cf7557b871094bda3d269972e|12|VIP|
|25b703950d3e71b5a2943534a31ae2ba|12|VIP|
|0b7e1cc1bec3e96ed4490c12ab0535c9|12|VIP|
|ac1199e07a382c4b92e2bf1e0f179772|12|VIP|
|84b412c274f594af3d17c9434036e317|12|VIP|
|78d7324240ce5b1c52e410a385319973|12|VIP|
|3b28f0054114806f37621c311da2dfdd|12|VIP|
|b8dc1446784e02a8753fba5ec915ce3c|12|VIP|