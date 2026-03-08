-- CUSTOMER COHORT ANALYSIS

with first_purchase as (
	select o.customer_id,
		   min(o.order_date) as first_purchase_date
	from orders o
    join order_items oi 
		on o.order_id = oi.order_id
    where oi.item_status = 'Completed'
    group by o.customer_id	
),
cohort_data as (
	select o.customer_id,
		   date_format(f.first_purchase_date, '%Y-%m') as cohort_month,
           timestampdiff(month, f.first_purchase_date,o.order_date) as cohort_index
	from orders o
    join order_items oi 
		on o.order_id = oi.order_id
    join first_purchase f
		on o.customer_id = f.customer_id
    where oi.item_status = 'Completed'
    group by o.customer_id, cohort_index, cohort_month
),
cohort_table as (
	select cohort_month, 
		   cohort_index, 
		   count(distinct customer_id) as retained_customers
	from cohort_data
    group by cohort_month, cohort_index
)
select cohort_month, 
	   cohort_index,
       retained_customers,
	   round(
			  retained_customers * 100.0 / first_value(retained_customers) 
					over(partition by cohort_month order by cohort_index),
			2) as retention_pct
from cohort_table
order by cohort_month, cohort_index;








   
           
           