CREATE OR REPLACE PROCEDURE pr_place_order(
    IN p_buyer_id INT,
    IN p_address_id INT,
    IN p_discount_code VARCHAR(50),
    IN p_product_ids INT[],
    IN p_quantities INT[],
    OUT p_generated_order_id INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_buyer_exists BOOLEAN;
    v_buyer_status VARCHAR(20);
    v_address_exists BOOLEAN;
    v_prod_active BOOLEAN;
    v_stock INT;
    v_price DECIMAL(12,2);
    v_subtotal DECIMAL(12,2) := 0.00;
    v_coupon_type VARCHAR(10);
    v_coupon_value DECIMAL(12,2);
    v_coupon_min_price DECIMAL(12,2);
    v_discount_amount DECIMAL(12,2) := 0.00;
    v_send_cost DECIMAL(12,2) := 25000.00;
    v_final_total DECIMAL(12,2) := 0.00;
    i INT;
BEGIN
    SELECT EXISTS(SELECT 1 FROM Buyer WHERE id = p_buyer_id) INTO v_buyer_exists;
    IF NOT v_buyer_exists THEN
        RAISE EXCEPTION 'ERROR: Buyer not found.';
    END IF;

    SELECT status INTO v_buyer_status FROM Buyer WHERE id = p_buyer_id;
    IF v_buyer_status != 'active' THEN
        RAISE EXCEPTION 'ERROR: Buyer account is not active.';
    END IF;

    SELECT EXISTS(SELECT 1 FROM Address WHERE address_id = p_address_id AND buyer_id = p_buyer_id) INTO v_address_exists;
    IF NOT v_address_exists THEN
        RAISE EXCEPTION 'ERROR: Address not found or does not belong to this buyer.';
    END IF;

    IF array_length(p_product_ids, 1) IS NULL OR array_length(p_product_ids, 1) != array_length(p_quantities, 1) THEN
        RAISE EXCEPTION 'ERROR: Product list and quantities do not match.';
    END IF;

    INSERT INTO "Order" (buyer_id, address_id, register_date, total, send_cost, discount, status, coupon_code)
    VALUES (p_buyer_id, p_address_id, CURRENT_TIMESTAMP, 0.00, v_send_cost, 0.00, 'pending', p_discount_code)
    RETURNING id INTO p_generated_order_id;

    FOR i IN 1 .. array_length(p_product_ids, 1) LOOP
        SELECT active, price INTO v_prod_active, v_price FROM Product WHERE id = p_product_ids[i];
        IF v_price IS NULL THEN
            RAISE EXCEPTION 'ERROR: Product with ID % does not exist.', p_product_ids[i];
        END IF;
        IF NOT v_prod_active THEN
            RAISE EXCEPTION 'ERROR: Product with ID % is inactive.', p_product_ids[i];
        END IF;

        SELECT quantity_count INTO v_stock FROM Storage_Quantity WHERE product_id = p_product_ids[i];
        IF v_stock IS NULL OR v_stock < p_quantities[i] THEN
            RAISE EXCEPTION 'ERROR: Insufficient stock for product %. Available: %', p_product_ids[i], COALESCE(v_stock, 0);
        END IF;

        INSERT INTO Order_item (order_id, product_id, quantity, unit_price)
        VALUES (p_generated_order_id, p_product_ids[i], p_quantities[i], v_price);

        UPDATE Storage_Quantity
        SET quantity_count = quantity_count - p_quantities[i],
            last_update_date = CURRENT_TIMESTAMP
        WHERE product_id = p_product_ids[i];

        v_subtotal := v_subtotal + (p_quantities[i] * v_price);
    END LOOP;

    IF p_discount_code IS NOT NULL AND p_discount_code != '' THEN
        SELECT type, value, min_price INTO v_coupon_type, v_coupon_value, v_coupon_min_price
        FROM Coupon
        WHERE code = p_discount_code;

        IF v_coupon_type IS NOT NULL AND v_subtotal >= v_coupon_min_price THEN
            IF v_coupon_type = 'percent' THEN
                v_discount_amount := (v_subtotal * v_coupon_value) / 100.00;
            ELSIF v_coupon_type = 'amount' THEN
                v_discount_amount := v_coupon_value;
            END IF;
        END IF;
    END IF;

    v_final_total := v_subtotal - v_discount_amount + v_send_cost;
    IF v_final_total < 0 THEN
        v_final_total := 0.00;
    END IF;

    UPDATE "Order"
    SET total = v_final_total,
        discount = v_discount_amount
    WHERE id = p_generated_order_id;
END;
$$;


CREATE OR REPLACE PROCEDURE pr_register_payment(
    IN p_order_id INT,
    IN p_fee DECIMAL(12,2),
    IN p_pay_way VARCHAR(50),
    IN p_tracking_code VARCHAR(100),
    IN p_status VARCHAR(20)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_order_exists BOOLEAN;
    v_expected_total DECIMAL(12,2);
    v_current_status VARCHAR(20);
BEGIN
    SELECT EXISTS(SELECT 1 FROM "Order" WHERE id = p_order_id) INTO v_order_exists;
    IF NOT v_order_exists THEN
        RAISE EXCEPTION 'ERROR: Order not found.';
    END IF;

    SELECT total, status INTO v_expected_total, v_current_status FROM "Order" WHERE id = p_order_id;

    IF v_current_status = 'cancelled' THEN
        RAISE EXCEPTION 'ERROR: Order is cancelled.';
    END IF;
    IF v_current_status IN ('paid', 'processing', 'shipped', 'delivered') AND p_status = 'successful' THEN
        RAISE EXCEPTION 'ERROR: Order is already paid.';
    END IF;

    INSERT INTO Pay (code, order_id, fee, pay_way, status, time)
    VALUES (p_tracking_code, p_order_id, p_fee, p_pay_way, p_status, CURRENT_TIMESTAMP);

    IF p_status = 'successful' THEN
        IF p_fee < v_expected_total THEN
            RAISE EXCEPTION 'ERROR: Insufficient payment fee. Expected: %, Got: %', v_expected_total, p_fee;
        END IF;

        UPDATE "Order"
        SET status = 'paid'
        WHERE id = p_order_id;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE pr_cancel_order(
    IN p_order_id INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_order_exists BOOLEAN;
    v_current_status VARCHAR(20);
    v_item RECORD;
BEGIN
    SELECT EXISTS(SELECT 1 FROM "Order" WHERE id = p_order_id) INTO v_order_exists;
    IF NOT v_order_exists THEN
        RAISE EXCEPTION 'ERROR: Order not found.';
    END IF;

    SELECT status INTO v_current_status FROM "Order" WHERE id = p_order_id;

    IF v_current_status IN ('shipped', 'delivered') THEN
        RAISE EXCEPTION 'ERROR: Order already shipped or delivered.';
    END IF;
    IF v_current_status = 'cancelled' THEN
        RAISE EXCEPTION 'ERROR: Order is already cancelled.';
    END IF;

    FOR v_item IN (SELECT product_id, quantity FROM Order_item WHERE order_id = p_order_id) LOOP
        UPDATE Storage_Quantity
        SET quantity_count = quantity_count + v_item.quantity,
            last_update_date = CURRENT_TIMESTAMP
        WHERE product_id = v_item.product_id;
    END LOOP;

    UPDATE "Order"
    SET status = 'cancelled'
    WHERE id = p_order_id;
END;
$$;