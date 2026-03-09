########################################################
# 3. Customer Segmentation
########################################################

INSERT INTO customer_segments
(customer_id,segment_name,segment_rank,assigned_date)

SELECT

customer_id,

CASE
WHEN customer_id<=420 THEN 'High'
WHEN customer_id<=1400 THEN 'Medium'
WHEN customer_id<=2625 THEN 'Low'
WHEN customer_id<=3150 THEN 'One-Time'
ELSE 'Dormant'
END,

CASE
WHEN customer_id<=420 THEN 1
WHEN customer_id<=1400 THEN 2
WHEN customer_id<=2625 THEN 3
WHEN customer_id<=3150 THEN 4
ELSE 5
END,

'2025-01-01'

FROM customers;