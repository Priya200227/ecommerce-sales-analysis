########################################################
# 1. Generate Customers
########################################################

SET SESSION cte_max_recursion_depth = 4000;

INSERT INTO customers (customer_name, email, city, signup_date)

WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 3500
)

SELECT 
    CONCAT('Customer_', n),

    CONCAT(
        'customer', n, '@',
        ELT(FLOOR(1 + (RAND()*3)),
        'gmail.com','yahoo.com','outlook.com')
    ),

    ELT(FLOOR(1 + (RAND()*8)),
        'Bengaluru','Mumbai','Delhi','Hyderabad',
        'Pune','Chennai','Kolkata','Ahmedabad'),

    DATE_ADD('2024-01-01',
        INTERVAL FLOOR(POW(RAND(),1.2) * 365) DAY)

FROM seq;



