

CREATE OR REPLACE VIEW vw_summary_orders_customer AS
SELECT
    b.id AS buyer_id,
    b.first_name,
    b.last_name,
    b.phone AS customer_phone,
    COUNT(o.id) AS total_orders_count,
    COALESCE(SUM(o.total), 0.00) AS total_orders_amount,
    MAX(o.register_date) AS last_order_date
FROM Buyer b
LEFT JOIN "Order" o ON b.id = o.buyer_id
GROUP BY b.id, b.first_name, b.last_name, b.phone;



CREATE OR REPLACE VIEW vw_status_sales_seller AS
SELECT
    s.eco_num AS seller_code,
    s.bus_name AS seller_name,
    s.phone AS seller_phone,
    (SELECT COUNT(*) FROM Product p WHERE p.seller_eco_num = s.eco_num AND p.active = TRUE) AS active_products_count,
    COUNT(DISTINCT o.id) AS successful_orders_count,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_sales_revenue
FROM Seller s
LEFT JOIN Product p ON s.eco_num = p.seller_eco_num
LEFT JOIN Order_item oi ON p.id = oi.product_id
LEFT JOIN "Order" o ON oi.order_id = o.id AND o.status IN ('paid', 'processing', 'shipped', 'delivered')
GROUP BY s.eco_num, s.bus_name, s.phone;


CREATE OR REPLACE VIEW vw_recent_orders_30days AS
SELECT
    o.buyer_id,
    o.id AS order_id,
    o.register_date AS order_date,
    o.status AS order_status,
    oi.product_id,
    p.details AS product_name,
    oi.quantity AS ordered_quantity,
    oi.unit_price AS unit_price_at_purchase,
    (oi.quantity * oi.unit_price) AS item_final_price
FROM "Order" o
JOIN Order_item oi ON o.id = oi.order_id
JOIN Product p ON oi.product_id = p.id
WHERE o.register_date >= CURRENT_TIMESTAMP - INTERVAL '30 days';



CREATE OR REPLACE VIEW vw_alerts_inventory AS
SELECT
    p.id AS product_id,
    p.details AS product_name,
    s.quantity_count AS current_stock,
    s.warning_number AS stock_threshold,
    p.price AS unit_price,
    p.seller_eco_num
FROM Product p
JOIN Storage_Quantity s ON p.id = s.product_id
WHERE s.quantity_count <= s.warning_number;