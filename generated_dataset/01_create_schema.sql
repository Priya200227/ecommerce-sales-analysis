/* =====================================================
   E-Commerce Synthetic Data Generation
   Database : style_union
   ===================================================== */

CREATE DATABASE IF NOT EXISTS style_union;
USE style_union;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE customer_segments;
TRUNCATE TABLE products;
TRUNCATE TABLE customers;

SET FOREIGN_KEY_CHECKS = 1;

