-- PRODUCT PERFORMANCE BASE TABLE
with product_metrics as (
	select p.product_id, p.product_name, p.category,
		   sum(case when oi.item_status = 'Completed' 
					then oi.quantity else 0 end) as units_sold,
           sum(case when oi.item_status = 'Completed' 
					then oi.quantity * oi.price_at_purchase else 0 end) as net_revenue,
			count(*) as total_items,
            sum(case when oi.item_status = 'Returned' 
					then 1 else 0 end) as returned_items
	from products p
    join order_items oi on p.product_id = oi.product_id
    group by p.product_id, p.product_name, p.category
)
-- select * from product_metrics;

-- TOP PRODUCTS BY REVENUE
select product_name, category, units_sold, net_revenue,
	   rank() over(order by net_revenue desc) as revenue_rank 
from product_metrics
order by revenue_rank limit 10;
-- Business meaning: Top products driving company revenue.


-- TOP PRODUCTS BY UNITS SOLD
select product_name, category, units_sold, net_revenue,
	   rank() over(order by units_sold desc) as demand_rank 
from product_metrics
order by demand_rank limit 10;
-- Business meaning: Top products driving company revenue.


-- PRODUCT RETURN RATE
select product_name, category, returned_items, net_revenue,
	   round(returned_items * 100.0 / total_items, 2) as return_rate
from product_metrics
order by return_rate desc limit 10;
-- Business meaning: High return rate products cause: logistics cost,inventory issues,margin loss 

        
-- PRODUCT REVENUE CONTRIBUTION %
select product_name, net_revenue,
	   round(net_revenue * 100.0 / sum(net_revenue) over(),2) as revenue_pct,
       rank() over(order by net_revenue desc) as revenue_rank
from product_metrics
order by revenue_rank;
-- Business meaning: shows which products contribute most revenue.


-- CATEGORY PRODUCT PERFORMANCE
select category,
	   count(product_id) as total_products,
       sum(units_sold) as units_sold,
       sum(net_revenue) as revenue
from product_metrics
group by category
order by revenue desc;
-- Business question: Which category portfolio is strongest?


-- LOW PERFORMING PRODUCTS
select product_name, category, units_sold, net_revenue
from product_metrics
where units_sold < 10
order by net_revenue;
-- Companies constantly look for products to remove or discount.






















