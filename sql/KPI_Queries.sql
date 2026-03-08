-- First KPI Block: Gross_Revenue, Net_Revenue, Total_orders, Completed_orders
with order_summary as (
	select o.order_id, o.order_status,
			oi.quantity * oi.price_at_purchase as revenue
            from orders o
            join order_items oi
	        on o.order_id = oi.order_id
)
select	
		sum(revenue) as gross_revenue,
            
		sum(case when order_status = 'Completed' 
					 then revenue
					 else 0 end ) as net_revenue,
					 
		count(distinct order_id) as total_orders,
			
		count(distinct case 
					when order_status = 'Completed' then order_id 
					else 0 end ) as completed_orders,
					
		sum(case when order_status = 'Completed' 
					 then revenue
					 else 0 end ) 
		/
		nullif(count(distinct case 
					when order_status = 'Completed' then order_id 
					end), 0) as net_aov
from order_summary;
 

-- Revenue per Category
with metrics as (
	select p.category,oi.item_status,
		   (oi.quantity * oi.price_at_purchase) as line_revenue
	from order_items oi 
    join products p on oi.product_id = p.product_id
    where oi.item_status != 'Cancelled'
),
category_revenue as 
(
	select category,
			sum(line_revenue) as gross_revenue,
			sum(case when item_status = 'Completed' then line_revenue else 0 end) as net_revenue
	from metrics
    group by category
)
select category, gross_revenue, net_revenue,
		(gross_revenue - net_revenue) as return_loss,
        round(((gross_revenue - net_revenue) / nullif(gross_revenue,0))* 100.0,2) as return_rate
from category_revenue
order by gross_revenue desc;


-- CATEGORY ANALYSIS
with metrics as (
	select p.category,oi.item_status,
		   (oi.quantity * oi.price_at_purchase) as line_revenue
	from order_items oi 
    join products p on oi.product_id = p.product_id
    where oi.item_status != 'Cancelled'
),
category_revenue as 
(
	select category,
			sum(line_revenue) as gross_revenue,
			sum(case when item_status = 'Completed' then line_revenue else 0 end) as net_revenue
	from metrics
    group by category
)
select category, net_revenue,
	round(net_revenue / sum(net_revenue) over () * 100,2) as contribution_pct,
    rank() over (order by net_revenue desc) as rev_rank,
    round(
		(sum(net_revenue) over (order by net_revenue desc) / sum(net_revenue) over ()) * 100,2
        ) as cummulative_pct
from category_revenue
order by rev_rank asc;


-- GROWTH ANALYSIS
with monthly_revenue as (
	select
		date_format(o.order_date, '%Y-%m') as monthly,
		sum(case 
				when oi.item_status = 'Completed' then oi.quantity * oi.price_at_purchase
				else 0 end ) as monthly_net_revenue,
        count(distinct case 
							when oi.item_status = 'Completed' then o.order_id 
							end) as monthly_orders
    from orders o
    join order_items oi on o.order_id = oi.order_id
    group by monthly
),
monthly_growth as (
	select 
			monthly, monthly_net_revenue, monthly_orders,
			lag(monthly_net_revenue) over (order by monthly) as previous_month_revenue,
            sum(monthly_net_revenue) over (order by monthly) as running_total_revenue
	from monthly_revenue
)
select monthly, monthly_net_revenue,monthly_orders,
		monthly_net_revenue -  previous_month_revenue as mom_revenue_change,
		round (
				(monthly_net_revenue - previous_month_revenue) * 100.0  
                 / nullif(previous_month_revenue,0),2) as mom_growth_pct
from monthly_growth
order by monthly;



























    