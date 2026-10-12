# E-Commerce Database Project

A PostgreSQL database project modeling the core data and workflows of an e-commerce platform. It covers customers and addresses, sellers, products and categories, inventory, coupons, orders, payments, and shipping. The project is organized into SQL scripts for schema creation, sample data, indexes, reporting views, stored procedures, transaction tests, and database roles.

## Features

- **Relational schema:** tables connected with primary keys, foreign keys, and constraints.
- **Sample data:** example customers, sellers, products, inventory, coupons, orders, payments, and shipments.
- **Indexes:** indexes for common order, product, payment, and shipping lookups.
- **Reporting views:** customer order summaries, seller sales summaries, recent order items, and low-stock alerts.
- **Stored procedures:**
  - `pr_place_order` validates the buyer, address, products, and stock; creates an order; updates inventory; and applies an eligible coupon.
  - `pr_register_payment` records a payment and marks the order as paid after a successful payment.
  - `pr_cancel_order` cancels eligible orders and restores inventory.
- **Role-based access control:** roles for administrators, sellers, support, warehouse staff, and backend/reporting access.
- **SQL test scenarios:** examples of successful and expected-failure procedure calls.

## ER-Model diagram
<img width="1571" height="1029" alt="phase0_ER" src="https://github.com/user-attachments/assets/1578170d-64dc-4d49-9e8f-596a025c01a0" />


## Repository layout

| File | Purpose |
|---|---|
| `phase2-create.sql` | Creates the database tables, constraints, and relationships. |
| `phase3-insert.sql` | Inserts sample data and includes example queries. |
| `phase4_index.sql` | Creates indexes to support common lookups. |
| `phase5_view.sql` | Defines reporting and inventory views. |
| `phase6_procedure.sql` | Defines order placement, payment registration, and order cancellation procedures. |
| `phase7-transaction.sql` | Runs example procedure calls and expected-failure scenarios. |
| `phase8-roles.sql` | Creates database roles/users and grants permissions. |
| `Report.pdf` | Project report/documentation. |

## Requirements

- PostgreSQL (with support for PL/pgSQL procedures)
- A PostgreSQL client, such as `psql` or pgAdmin

## Setup

1. Create a database, for example:

   ```sql
   CREATE DATABASE ecommerce_db;
   ```

2. Connect to the new database using `psql` or your preferred PostgreSQL client.

3. Run the scripts **in this order**:

   ```bash
   psql -d ecommerce_db -v ON_ERROR_STOP=1 -f phase2-create.sql
   psql -d ecommerce_db -v ON_ERROR_STOP=1 -f phase3-insert.sql
   psql -d ecommerce_db -v ON_ERROR_STOP=1 -f phase4_index.sql
   psql -d ecommerce_db -v ON_ERROR_STOP=1 -f phase5_view.sql
   psql -d ecommerce_db -v ON_ERROR_STOP=1 -f phase6_procedure.sql
   ```

   Run these commands from the directory containing the SQL files. If your PostgreSQL server requires credentials or a host/port, provide them through your normal `psql` connection options or environment.

4. Review `phase7-transaction.sql` separately when you are ready to test the procedures. It changes database state, and some scenarios intentionally raise errors. Use a disposable development database and inspect the script before running it.

5. Review `phase8-roles.sql` separately and run it only with an account permitted to create roles and users. It creates database roles and login users, and may require adapting to your environment.

> **Note:** The scripts are not necessarily safe to rerun as a complete sequence. For a clean test, use a fresh database. The schema uses the quoted table name `"Order"`, so queries must preserve its capitalization and quotation marks.

## Reporting views

The project defines these views:

- `vw_summary_orders_customer` — order count, total order amount, and most recent order date per customer.
- `vw_status_sales_seller` — seller product and sales summary.
- `vw_recent_orders_30days` — line items from orders placed in the last 30 days.
- `vw_alerts_inventory` — products whose stock is at or below their warning threshold.

Example:

```sql
SELECT *
FROM vw_alerts_inventory
ORDER BY current_stock ASC;
```

## Stored procedure examples

The procedures are defined in `phase6_procedure.sql`. Example calls (use IDs and values that exist in your database):

```sql
-- Place an order; the final argument receives the generated order ID.
CALL pr_place_order(
    1,                 -- buyer ID
    1,                 -- address ID belonging to that buyer
    NULL,              -- optional coupon code
    ARRAY[1],           -- product IDs
    ARRAY[1],           -- matching quantities
    NULL                -- OUT parameter placeholder for clients that require it
);

-- Register a payment (use a unique tracking code).
CALL pr_register_payment(
    1,
    1000.00,
    'gateway',
    'EXAMPLE-TRANSACTION-001',
    'pending'
);

-- Cancel an eligible order.
CALL pr_cancel_order(1);
```

Check your SQL client’s handling of `OUT` parameters when calling `pr_place_order`; the exact call syntax may vary by client. Ensure the payment fee and order status are appropriate for the scenario being tested.
