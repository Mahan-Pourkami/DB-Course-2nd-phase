-- ============================================================================
-- DB Project Phase 3 - Data Insertion and Testing Queries
-- Faculty of Computer Engineering, Amirkabir University of Technology (AUT)
-- Spring 1405
-- File: phase3-insert.sql
-- ============================================================================

-- 1. Insert 10 rows into Buyer Table
INSERT INTO Buyer (first_name, last_name, phone, email, register_date, status) VALUES
('Ali', 'Rezai', '09121111111', 'ali.rezai@gmail.com', '2026-01-15', 'active'),
('Zahra', 'Ahmadi', '09122222222', 'zahra.ahmadi@yahoo.com', '2026-02-10', 'active'),
('Mohammad', 'Karimi', '09123333333', 'm.karimi@outlook.com', '2026-03-01', 'active'),
('Fatemeh', 'Hosseini', '09124444444', 'f.hosseini@gmail.com', '2026-03-12', 'active'),
('Reza', 'Mousavi', '09125555555', 'reza.m@gmail.com', '2026-04-05', 'suspended'),
('Maryam', 'Sadati', '09126666666', 'm.sadati@gmail.com', '2026-04-20', 'active'),
('Hossein', 'Yousefi', '09127777777', 'h.yousefi@yahoo.com', '2026-05-02', 'active'),
('Sara', 'Taghavi', '09128888888', 'sara.t@gmail.com', '2026-05-18', 'active'),
('Amir', 'Naderi', '09129999999', 'amir.naderi@gmail.com', '2026-06-01', 'active'),
('Neda', 'Ghasemi', '09120000000', 'neda.gh@gmail.com', '2026-06-14', 'inactive');

-- 2. Insert 10 rows into Address Table (Some buyers have multiple addresses)
INSERT INTO Address (buyer_id, city, street, no) VALUES
(1, 'Tehran', 'Vaniak St, No 12', '12'),
(1, 'Tehran', 'Azadi St, Alley 4', '5'),
(2, 'Isfahan', 'Chahar Bagh St', '45'),
(3, 'Mashhad', 'Ahmad Abad Ave', '112'),
(4, 'Shiraz', 'Zand St', '88'),
(5, 'Tabriz', 'Imam St', '24'),
(6, 'Tehran', 'Shariati St', '301'),
(7, 'Karaj', 'Gohardasht', '14'),
(8, 'Isfahan', 'Khajou St', '9'),
(9, 'Tehran', 'Sattarkhan St', '77');

-- 3. Insert 10 rows into Seller Table
INSERT INTO Seller (eco_num, bus_name, phone, email, is_confirmed, register_date) VALUES
('ECO-1001', 'DigiStore', '02188881111', 'info@digistore.com', TRUE, '2025-01-01'),
('ECO-1002', 'TechnoLand', '02188882222', 'sales@technoland.ir', TRUE, '2025-03-15'),
('ECO-1003', 'BookWorld', '02188883333', 'contact@bookworld.com', TRUE, '2025-06-10'),
('ECO-1004', 'FashionHub', '02188884444', 'support@fashionhub.com', TRUE, '2025-09-20'),
('ECO-1005', 'HomeApplianceCo', '02188885555', 'ceo@homeapp.ir', TRUE, '2025-11-05'),
('ECO-1006', 'SportPlus', '02188886666', 'sportplus@gmail.com', FALSE, '2026-01-10'),
('ECO-1007', 'SuperMarketOnline', '02188887777', 'smo@online.com', TRUE, '2026-02-20'),
('ECO-1008', 'ToyTown', '02188888888', 'toys@town.com', TRUE, '2026-03-15'),
('ECO-1009', 'BeautyZone', '02188889999', 'beauty@zone.ir', FALSE, '2026-04-01'),
('ECO-1010', 'OfficeSupply', '02188880000', 'office@supply.com', TRUE, '2026-05-10');

-- 4. Insert 10 rows into Category Table (Including Sub-Categories)
INSERT INTO Category (name, parent_category_id) VALUES
('Electronics', NULL), -- ID 1
('Books', NULL),       -- ID 2
('Clothing', NULL),    -- ID 3
('Smartphones', 1),    -- ID 4 (Sub of Electronics)
('Laptops', 1),        -- ID 5 (Sub of Electronics)
('Novels', 2),         -- ID 6 (Sub of Books)
('Academic', 2),       -- ID 7 (Sub of Books)
('Shoes', 3),          -- ID 8 (Sub of Clothing)
('Home & Kitchen', NULL), -- ID 9
('Appliances', 9);     -- ID 10 (Sub of Home)

-- 5. Insert 10 rows into Product Table
INSERT INTO Product (details, active, price, seller_eco_num) VALUES
('iPhone 15 Pro 256GB', TRUE, 60000000.00, 'ECO-1001'), -- ID 1
('Samsung Galaxy S24 Ultra', TRUE, 55000000.00, 'ECO-1002'), -- ID 2
('Asus ROG Strix Laptop', TRUE, 85000000.00, 'ECO-1002'), -- ID 3
('Database System Concepts Book', TRUE, 450000.00, 'ECO-1003'), -- ID 4
('Introduction to Algorithms (CLRS)', TRUE, 600000.00, 'ECO-1010'), -- ID 5
('Running Shoes Nike Air', TRUE, 4500000.00, 'ECO-1004'), -- ID 6
('Leather Jacket Brown', TRUE, 7000000.00, 'ECO-1004'), -- ID 7
('Microwave Oven 30L', TRUE, 12000000.00, 'ECO-1005'), -- ID 8
('Electric Kettle 1.7L', TRUE, 2500000.00, 'ECO-1005'), -- ID 9
('Board Game Monopoly', TRUE, 800000.00, 'ECO-1008'); -- ID 10

-- 5b. Populate Product_Category_Mapping
INSERT INTO Product_Category_Mapping (product_id, category_id) VALUES
(1, 4), (2, 4), (3, 5), (4, 7), (5, 7), (6, 8), (7, 3), (8, 10), (9, 10), (10, 2);

-- 6. Insert 10 rows into Storage_Quantity Table (Weak Entity)
INSERT INTO Storage_Quantity (product_id, quantity_count, location, warning_number) VALUES
(1, 25, 'Aisle A-Shelf 3', 5),
(2, 3, 'Aisle A-Shelf 4', 5),  -- Low stock trigger
(3, 8, 'Aisle B-Shelf 1', 2),
(4, 50, 'Aisle C-Shelf 2', 10),
(5, 1, 'Aisle C-Shelf 3', 5),  -- Low stock trigger
(6, 15, 'Aisle D-Shelf 1', 4),
(7, 12, 'Aisle D-Shelf 2', 3),
(8, 6, 'Aisle E-Shelf 5', 2),
(9, 2, 'Aisle E-Shelf 6', 3),  -- Low stock trigger
(10, 40, 'Aisle F-Shelf 1', 5);

-- 7. Insert 10 rows into Coupon Table
INSERT INTO Coupon (code, type, value, min_price, max_usage) VALUES
('WELCOME100', 'amount', 100000.00, 500000.00, 100),
('GOLDEN20', 'percent', 20.00, 2000000.00, 10),
('TECH5', 'percent', 5.00, 10000000.00, 50),
('BOOKS25', 'percent', 25.00, 300000.00, 200),
('SUMMEROFF', 'amount', 500000.00, 3000000.00, 5),
('WINTER10', 'percent', 10.00, 1000000.00, 50),
('BLACKFRIDAY', 'amount', 2000000.00, 15000000.00, 10),
('EID405', 'percent', 15.00, 500000.00, 500),
('OFFER2', 'amount', 200000.00, 1000000.00, 20),
('FREE_SHIP', 'amount', 150000.00, 1000000.00, 1000);

-- 8. Insert 10 rows into Order Table (Dates around June/July 2026)
INSERT INTO "Order" (buyer_id, address_id, register_date, total, send_cost, discount, status, coupon_code) VALUES
(1, 1, '2026-06-20 14:30:00', 60000000.00, 150000.00, 0.00, 'delivered', NULL),
(1, 2, '2026-07-15 10:00:00', 55000000.00, 150000.00, 2000000.00, 'paid', 'BLACKFRIDAY'),
(2, 3, '2026-07-10 11:15:00', 4500000.00, 0.00, 500000.00, 'delivered', 'SUMMEROFF'),
(3, 4, '2026-07-12 16:45:00', 900000.00, 150000.00, 100000.00, 'pending', 'WELCOME100'),
(4, 5, '2026-07-14 09:30:00', 14500000.00, 150000.00, 0.00, 'shipped', NULL),
(6, 7, '2026-07-01 12:00:00', 85000000.00, 0.00, 0.00, 'delivered', NULL),
(7, 8, '2026-07-05 18:20:00', 5000000.00, 150000.00, 0.00, 'cancelled', NULL),
(8, 9, '2026-07-16 14:00:00', 600000.00, 150000.00, 150000.00, 'pending', 'FREE_SHIP'),
(9, 10, '2026-07-11 20:10:00', 800000.00, 150000.00, 0.00, 'processing', NULL),
(10, 1, '2026-07-13 15:30:00', 12000000.00, 150000.00, 0.00, 'paid', NULL);

-- 9. Insert 10 rows into Order_item Table
INSERT INTO Order_item (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 60000000.00),
(2, 2, 1, 55000000.00),
(3, 6, 1, 4500000.00),
(4, 4, 2, 450000.00),
(5, 8, 1, 12000000.00),
(5, 9, 1, 2500000.00),
(6, 3, 1, 85000000.00),
(7, 9, 2, 2500000.00),
(8, 5, 1, 600000.00),
(9, 10, 1, 800000.00);

-- 10. Insert 10 rows into Pay Table
INSERT INTO Pay (code, order_id, fee, pay_way, status, time) VALUES
('TRX-9901', 1, 60150000.00, 'gateway', 'successful', '2026-06-20 14:35:00'),
('TRX-9902', 2, 53150000.00, 'gateway', 'successful', '2026-07-15 10:05:00'),
('TRX-9903', 3, 4000000.00, 'wallet', 'successful', '2026-07-10 11:20:00'),
('TRX-9904', 4, 950000.00, 'gateway', 'failed', '2026-07-12 16:50:00'),
('TRX-9905', 4, 950000.00, 'gateway', 'pending', '2026-07-12 17:00:00'),
('TRX-9906', 5, 14650000.00, 'gateway', 'successful', '2026-07-14 09:35:00'),
('TRX-9907', 6, 85000000.00, 'gateway', 'successful', '2026-07-01 12:05:00'),
('TRX-9908', 7, 5150000.00, 'gateway', 'failed', '2026-07-05 18:25:00'),
('TRX-9909', 9, 950000.00, 'cod', 'pending', '2026-07-11 20:15:00'),
('TRX-9910', 10, 12150000.00, 'wallet', 'successful', '2026-07-13 15:35:00');

-- 11. Insert 10 rows into Post Table
INSERT INTO Post (code, order_id, company, send_time, recieve_time, status) VALUES
('POST-8801', 1, 'Tipax', '2026-06-21 09:00:00', '2026-06-23 14:00:00', 'delivered'),
('POST-8802', 2, 'NationalPost', NULL, NULL, 'preparing'),
('POST-8803', 3, 'SnellBox', '2026-07-11 10:00:00', '2026-07-11 12:30:00', 'delivered'),
('POST-8804', 5, 'Tipax', '2026-07-15 11:00:00', NULL, 'in_transit'),
('POST-8805', 6, 'NationalPost', '2026-07-02 08:30:00', '2026-07-04 11:00:00', 'delivered'),
('POST-8806', 9, 'SnappExpress', NULL, NULL, 'preparing');



SELECT * FROM "Order"
WHERE buyer_id = 1;


SELECT * FROM "Order"
WHERE buyer_id = 1
ORDER BY register_date DESC
LIMIT 5;

SELECT p.id, p.details, s.quantity_count, s.warning_number
FROM Product p
JOIN Storage_Quantity s ON p.id = s.product_id
WHERE s.quantity_count < s.warning_number;

SELECT s.eco_num, s.bus_name, SUM(oi.quantity * oi.unit_price) AS total_sales
FROM Seller s
JOIN Product p ON s.eco_num = p.seller_eco_num
JOIN Order_item oi ON p.id = oi.product_id
JOIN "Order" o ON oi.order_id = o.id
WHERE o.status IN ('paid', 'processing', 'shipped', 'delivered')
  AND o.register_date >= NOW() - INTERVAL '30 days'
GROUP BY s.eco_num, s.bus_name
HAVING SUM(oi.quantity * oi.unit_price) > 10000000.00;

SELECT DISTINCT o.id AS order_id, o.total, o.status AS order_status, p.code AS payment_code, p.status AS payment_status
FROM "Order" o
JOIN Pay p ON o.id = p.order_id
WHERE p.status IN ('pending', 'failed');

SELECT COUNT(*) AS total_orders_past_month
FROM "Order"
WHERE register_date >= NOW() - INTERVAL '30 days';
