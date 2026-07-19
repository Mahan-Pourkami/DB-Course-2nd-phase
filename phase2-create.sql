

-- 1. Buyer Table (Customers)
CREATE  TABLE IF NOT EXISTS Buyer (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    register_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT chk_buyer_status CHECK (status IN ('active', 'suspended', 'inactive'))
);

-- 2. Address Table
CREATE TABLE IF NOT EXISTS Address (
    address_id SERIAL PRIMARY KEY,
    buyer_id INT NOT NULL,
    city VARCHAR(50) NOT NULL,
    street VARCHAR(150) NOT NULL,
    no VARCHAR(10) NOT NULL, -- House/Plat number
    CONSTRAINT fk_address_buyer FOREIGN KEY (buyer_id) REFERENCES Buyer(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. Seller Table
CREATE TABLE IF NOT EXISTS Seller (
    eco_num VARCHAR(50) PRIMARY KEY, -- Economic code / Registration ID
    bus_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    is_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
    register_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 4. Category Table
CREATE TABLE IF NOT EXISTS Category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    parent_category_id INT,
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_category_id) REFERENCES Category(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 5. Product Table
CREATE TABLE IF NOT EXISTS Product (
    id SERIAL PRIMARY KEY,
    details TEXT,
    active BOOLEAN NOT NULL DEFAULT FALSE,
    price DECIMAL(12, 2) NOT NULL,
    seller_eco_num VARCHAR(50) NOT NULL,
    CONSTRAINT chk_product_price CHECK (price >= 0),
    CONSTRAINT fk_product_seller FOREIGN KEY (seller_eco_num) REFERENCES Seller(eco_num) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 5b. Product-Category Mapping Table
CREATE TABLE IF NOT EXISTS Product_Category_Mapping (
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (product_id, category_id),
    CONSTRAINT fk_mapping_product FOREIGN KEY (product_id) REFERENCES Product(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_mapping_category FOREIGN KEY (category_id) REFERENCES Category(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6. Storage_Quantity Table
CREATE TABLE IF NOT EXISTS Storage_Quantity (
    product_id INT PRIMARY KEY,
    quantity_count INT NOT NULL DEFAULT 0,
    location VARCHAR(100),
    last_update_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    warning_number INT NOT NULL DEFAULT 5,
    CONSTRAINT chk_storage_quantity CHECK (quantity_count >= 0),
    CONSTRAINT chk_storage_warning CHECK (warning_number >= 0),
    CONSTRAINT fk_storage_product FOREIGN KEY (product_id) REFERENCES Product(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 7. Coupon Table (Discounts)
CREATE TABLE IF NOT EXISTS Coupon (
    code VARCHAR(50) PRIMARY KEY,
    type VARCHAR(10) NOT NULL, --
    value DECIMAL(12, 2) NOT NULL,
    min_price DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    max_usage INT NOT NULL DEFAULT 1,
    CONSTRAINT chk_coupon_type CHECK (type IN ('percent', 'amount')),
    CONSTRAINT chk_coupon_value CHECK (value > 0),
    CONSTRAINT chk_coupon_min_price CHECK (min_price >= 0),
    CONSTRAINT chk_coupon_max_usage CHECK (max_usage > 0)
);

-- 8. Order Table
CREATE TABLE IF NOT EXISTS "Order" (
    id SERIAL PRIMARY KEY,
    buyer_id INT NOT NULL,
    address_id INT NOT NULL,
    register_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    send_cost DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    discount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    coupon_code VARCHAR(50),
    CONSTRAINT chk_order_total CHECK (total >= 0),
    CONSTRAINT chk_order_send_cost CHECK (send_cost >= 0),
    CONSTRAINT chk_order_discount CHECK (discount >= 0),
    CONSTRAINT chk_order_status CHECK (status IN ('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled')),
    CONSTRAINT fk_order_buyer FOREIGN KEY (buyer_id) REFERENCES Buyer(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_address FOREIGN KEY (address_id) REFERENCES Address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_coupon FOREIGN KEY (coupon_code) REFERENCES Coupon(code) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 9. Order_item Table
CREATE TABLE IF NOT EXISTS Order_item (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(12, 2) NOT NULL,
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (unit_price >= 0),
    CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES "Order"(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES Product(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 10. Pay Table
CREATE TABLE IF NOT EXISTS Pay (
    code VARCHAR(100) PRIMARY KEY,
    order_id INT NOT NULL,
    fee DECIMAL(12, 2) NOT NULL,
    pay_way VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_pay_fee CHECK (fee > 0),
    CONSTRAINT chk_pay_status CHECK (status IN ('pending', 'successful', 'failed')),
    CONSTRAINT fk_pay_order FOREIGN KEY (order_id) REFERENCES "Order"(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 11. Post Table
CREATE TABLE IF NOT EXISTS Post (
    code VARCHAR(100) PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    company VARCHAR(100) NOT NULL,
    send_time TIMESTAMP,
    recieve_time TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'preparing',
    CONSTRAINT chk_post_status CHECK (status IN ('preparing', 'picked_up', 'in_transit', 'delivered', 'returned')),
    CONSTRAINT fk_post_order FOREIGN KEY (order_id) REFERENCES "Order"(id) ON DELETE CASCADE ON UPDATE CASCADE
);

