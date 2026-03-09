########################################################
# 2. Generate Products
########################################################

SET SESSION cte_max_recursion_depth = 1000;

INSERT INTO products
(product_name, category, sub_category, gender, price)

WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 220
)

SELECT

    CONCAT('Product_', n),

    @cat := ELT(FLOOR(1 + (RAND()*3)),
        'Apparel','Footwear','Accessories'),

    CASE
        WHEN @cat='Apparel'
            THEN ELT(FLOOR(1 + RAND()*2),'T-Shirts','Jeans')

        WHEN @cat='Footwear'
            THEN 'Sneakers'

        ELSE 'Bags'
    END,

    ELT(FLOOR(1 + RAND()*3),
        'Men','Women','Unisex'),

    ROUND(

        CASE

            WHEN @cat='Footwear'
                THEN 3500 + RAND()*4500

            WHEN @cat='Apparel'
                THEN 800 + RAND()*2700

            ELSE
                200 + RAND()*1300

        END

    ,2)

FROM seq;