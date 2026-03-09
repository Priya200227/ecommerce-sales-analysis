########################################################
# 4. Generate Orders
########################################################

SET SESSION cte_max_recursion_depth = 50000;

INSERT INTO orders
(customer_id,order_date,order_status,payment_method)

WITH RECURSIVE order_slots AS (

SELECT 1 AS n

UNION ALL

SELECT n+1 FROM order_slots WHERE n<25
)

SELECT

c.customer_id,

DATE_ADD(
GREATEST(c.signup_date,'2024-01-01'),

INTERVAL FLOOR(

CASE
WHEN RAND()<0.35 THEN 270+(RAND()*90)
ELSE RAND()*365
END

) DAY
),

'Pending',

ELT(FLOOR(1 + RAND()*4),
'UPI','Credit Card','Debit Card','COD')

FROM customers c

JOIN customer_segments s
ON c.customer_id=s.customer_id

JOIN order_slots os

WHERE

(
s.segment_name='High'
AND os.n<=FLOOR(18+RAND()*8)
)

OR

(
s.segment_name='Medium'
AND os.n<=FLOOR(6+RAND()*5)
)

OR

(
s.segment_name='Low'
AND os.n<=FLOOR(2+RAND()*3)
)

OR

(
s.segment_name='One-Time'
AND os.n=1
);


########################################################
# 5. Assign Order Status
########################################################

UPDATE orders

SET order_status=

CASE

WHEN order_id%10<=6 THEN 'Completed'
WHEN order_id%10<=8 THEN 'Returned'
ELSE 'Cancelled'

END;


########################################################
# 6. Basket Size Generation
########################################################

CREATE TEMPORARY TABLE order_basket_size

SELECT

order_id,

CASE
WHEN RAND()<0.60 THEN 1
WHEN RAND()<0.85 THEN 2
WHEN RAND()<0.95 THEN 3
ELSE 4
END

AS basket_size

FROM orders;
