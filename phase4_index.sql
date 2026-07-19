
CREATE INDEX idx_order_buyer_date ON "Order" (buyer_id, register_date DESC);

CREATE INDEX idx_order_address ON "Order" (address_id);

CREATE INDEX idx_order_item_product ON Order_item (product_id);

CREATE INDEX idx_product_seller ON Product (seller_eco_num);

CREATE INDEX idx_pay_status ON Pay (status);

CREATE INDEX idx_post_status ON Post (status);