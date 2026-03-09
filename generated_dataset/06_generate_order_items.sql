########################################################
# 7. Generate Order Items
########################################################

SET SESSION cte_max_recursion_depth = 10;

INSERT INTO order_items
(order_id,product_id,quantity,price_at_purchase)

WITH RECURSIVE item_seq AS (

SELECT 1 AS n

UNION ALL

SELECT n+1 FROM item_seq WHERE n<4

)

SELECT

o.order_id,

FLOOR(1 + RAND()*220),

CASE
WHEN RAND()<0.75 THEN 1
WHEN RAND()<0.95 THEN 2
ELSE 3
END,

0

FROM orders o

JOIN order_basket_size b
ON o.order_id=b.order_id

JOIN item_seq s

WHERE s.n<=b.basket_size;


########################################################
# 8. Apply Price Variation
########################################################

UPDATE order_items oi

JOIN products p
ON oi.product_id=p.product_id

SET oi.price_at_purchase=
ROUND(p.price*(0.90 + RAND()*0.15),2);


########################################################
# 9. Clean Duplicate Products per Order
########################################################

CREATE TEMPORARY TABLE order_items_clean

SELECT

order_id,
product_id,

SUM(quantity) AS quantity,

ROUND(AVG(price_at_purchase),2) AS price_at_purchase

FROM order_items

GROUP BY order_id,product_id;


SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE order_items;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO order_items

SELECT * FROM order_items_clean;
