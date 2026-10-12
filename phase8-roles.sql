--create roles
CREATE ROLE role_shop_admin;
CREATE ROLE role_seller;
CREATE ROLE role_support;
CREATE ROLE role_warehouse;
CREATE ROLE role_backend_team;

--role shop admin :
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_shop_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_shop_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO role_shop_admin;
GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA public TO role_shop_admin;


--role seller
GRANT SELECT, INSERT, UPDATE ON Product TO role_seller;
GRANT SELECT, UPDATE ON Storage_Quantity TO role_seller;
GRANT SELECT ON Category, Product_Category_Mapping TO role_seller;
GRANT SELECT ON Order_item TO role_seller;


--role support
GRANT SELECT ON Buyer, Address, "Order", Order_item, Pay, Post, Product, Category TO role_support;
GRANT UPDATE(status) ON "Order" TO role_support;
GRANT UPDATE(status) ON Pay TO role_support;

--role warehouse
GRANT SELECT ON "Order", Order_item, Product, Category TO role_warehouse;
GRANT SELECT, UPDATE(quantity_count, last_update_date, location) ON Storage_Quantity TO role_warehouse;
GRANT SELECT, INSERT, UPDATE(status, send_time, recieve_time) ON Post TO role_warehouse;


--role backend
GRANT SELECT ON vw_summary_orders_customer TO role_backend_team;
GRANT SELECT ON vw_status_sales_seller TO role_backend_team;
GRANT SELECT ON vw_recent_orders_30days TO role_backend_team;
GRANT SELECT ON vw_alerts_inventory TO role_backend_team;


CREATE USER admin_user WITH PASSWORD 'Admin_Secure_Pass_1405';
GRANT role_shop_admin TO admin_user;


CREATE USER seller_user WITH PASSWORD 'Seller_Secret_Pass_9988';
GRANT role_seller TO seller_user;


CREATE USER support_user WITH PASSWORD 'Support_Pass_7766';
GRANT role_support TO support_user;


CREATE USER warehouse_user WITH PASSWORD 'Warehouse_Pass_1122';
GRANT role_warehouse TO warehouse_user;

CREATE USER backend_user WITH PASSWORD 'Backend_Pass_1234';
GRANT role_backend_team TO backend_user;