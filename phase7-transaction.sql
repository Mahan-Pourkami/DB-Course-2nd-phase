
-- 1. tr_place_order Tests

--tr_place_order : successful
DO $$
DECLARE
    v_order_id INT;
BEGIN
    CALL pr_place_order(2, 3, NULL, ARRAY[3], ARRAY[1], v_order_id);
    RAISE NOTICE 'Test 1 (Success): Order placed successfully. Generated ID: %', v_order_id;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Test 1 Failed: %', SQLERRM;
END $$;

-- tr_place_order: Unsuccessful case 1
DO $$
BEGIN
    CALL pr_place_order(999, 1, NULL, ARRAY[1], ARRAY[1], NULL);
    RAISE NOTICE 'Test 2 (Success): Order placed successfully.';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Test 2 (Expected Failure): Transaction rolled back. Reason: %', SQLERRM;
END $$;

-- tr_place_order: Unsuccessful case 2
DO $$
BEGIN
    CALL pr_place_order(1, 1, NULL, ARRAY[1], ARRAY[1000], NULL);
    RAISE NOTICE 'Test 3 (Success): Order placed successfully.';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Test 3 (Expected Failure): Transaction rolled back. Reason: %', SQLERRM;
END $$;


-- 2. tr_payment_order Tests

-- tr_payment_order: successful
DO $$
BEGIN
    CALL pr_register_payment(9, 150000.00, 'ZarinPal', 'TRC-SUCCESS-009', 'successful');
    RAISE NOTICE 'Test 4 (Success): Payment registered and order updated successfully.';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Test 4 Failed: %', SQLERRM;
END $$;

-- tr_payment_order: Unsuccessful case 1
DO $$
BEGIN
    CALL pr_register_payment(12, 1000.00, 'Saman', 'TRC-FAIL-012', 'successful');
    RAISE NOTICE 'Test 5 (Success): Payment registered successfully.';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Test 5 (Expected Failure): Transaction rolled back. Reason: %', SQLERRM;
END $$;

-- tr_payment_order: Unsuccessful case 2
DO $$
BEGIN
    UPDATE "Order" SET status = 'shipped' WHERE id = 1;

    CALL pr_register_payment(1, 1200000.00, 'Mellat', 'TRC-FAIL-001', 'successful');
    RAISE NOTICE 'Test 6 (Success): Payment registered successfully.';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Test 6 (Expected Failure): Transaction rolled back. Reason: %', SQLERRM;
END $$;

-- 3. tr_cancel_ord Tests

-- tr_cancel_ord: successful case
DO $$
BEGIN
    CALL pr_cancel_order(12);
    RAISE NOTICE 'Test 7 (Success): Order canceled and stock reverted successfully.';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Test 7 Failed: %', SQLERRM;
END $$;

-- tr_cancel_ord: Unsuccessful case 1
DO $$
BEGIN
    UPDATE "Order" SET status = 'shipped' WHERE id = 2;

    CALL pr_cancel_order(2);
    RAISE NOTICE 'Test 8 (Success): Order canceled successfully.';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Test 8 (Expected Failure): Transaction rolled back. Reason: %', SQLERRM;
END $$;

-- tr_cancel_ord: Unsuccessful case 2
DO $$
BEGIN
    CALL pr_cancel_order(9999);
    RAISE NOTICE 'Test 9 (Success): Order canceled successfully.';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Test 9 (Expected Failure): Transaction rolled back. Reason: %', SQLERRM;
END $$;