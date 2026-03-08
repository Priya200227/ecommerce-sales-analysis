with customer_summary as (
	select o.customer_id,
			count(distinct o.order_id) as completed_orders,
            sum(oi.quantity * oi.price_at_purchase) as net_revenue
    from orders o 
    join order_items oi on o.order_id = oi.order_id
    where oi.item_status = 'Completed'
    group by o.customer_id
)
select count(customer_id) as active_customer,
	   count(case when completed_orders >= 2 then customer_id end) as repeat_customers,
       round (count(case when completed_orders >= 2 then customer_id end) * 100.0 
       / nullif(count(customer_id),0),2 ) as repeat_rate_pct,
       round(avg(completed_orders),2) as avg_orders_per_active_cust,
       round(avg(net_revenue),2) as avg_rev_per_active_cust
from customer_summary;


-- CREATE CUSTOMER SUMMARY VIEW
create or replace view vw_customer_summary as
select o.customer_id,
		count(distinct o.order_id) as completed_orders,
		sum(oi.quantity * oi.price_at_purchase) as net_revenue
from orders o 	
join order_items oi on o.order_id = oi.order_id
where oi.item_status = 'Completed'
group by o.customer_id;

-- CUMULATIVE DISTRIBUTION
select customer_id, net_revenue,
	row_number() over (order by net_revenue desc) as revenue_rank,
	sum(net_revenue) over (order by net_revenue desc) as cumulative_revenue,
	sum(net_revenue) over () as total_revenue,
    round(
			(sum(net_revenue) over (order by net_revenue desc) * 100.0 
            / sum(net_revenue) over ()),2) as cumulative_revenue_pct
from vw_customer_summary
order by revenue_rank;

-- TOP 20% REVENUE CONTRIBUTION
with ranked_customers as (
	select customer_id, net_revenue,
		row_number() over (order by net_revenue desc) as revenue_rank,
        count(*) over () as total_customers
    from vw_customer_summary
)
select 
	   sum(net_revenue) as total_revenue,
	   sum(case 
				when revenue_rank <= total_customers * 0.20
				then net_revenue else 0 end) as revenue_top_20,
	   round(
			   (sum(case 
						when revenue_rank <= total_customers * 0.20
						then net_revenue else 0 end) * 100.0 
						/ sum(net_revenue)
				),2) as revenue_contribution_pct
from ranked_customers;

-- RETENTION STRATEGY
create or replace view vw_customer_summary as
select o.customer_id,
		count(distinct o.order_id) as completed_orders,
		sum(oi.quantity * oi.price_at_purchase) as net_revenue
from orders o 	
join order_items oi on o.order_id = oi.order_id
where oi.item_status = 'Completed'
group by o.customer_id;

/* -- Calculating thresholds
SELECT 
    completed_orders,
    COUNT(*) AS customer_count,
    NTILE(5) OVER (ORDER BY completed_orders)
FROM vw_customer_summary
GROUP BY completed_orders
ORDER BY completed_orders; */

select 
		sum(net_revenue) as total_revenue,
        -- revenue_segmentation
        sum(case when completed_orders >= 5 then net_revenue else 0 end) as retention_orders,
        -- segment_revenue / total_revenue
		round(sum(case when completed_orders >= 5 then net_revenue else 0 end) * 100.0 
				/ sum(net_revenue),2) as contribution_pct
from vw_customer_summary;

-- FREQUENCY DISTRIBUTION OF COMPLETED ORDERS
SELECT
    customer_segment,
    COUNT(*) AS customers,
    SUM(net_revenue) AS revenue,
    ROUND(SUM(net_revenue) * 100.0 / SUM(SUM(net_revenue)) OVER(),2) AS revenue_pct
FROM (
    SELECT
        customer_id,
        completed_orders,
        net_revenue,
        CASE
            WHEN completed_orders <= 2 THEN 'Bronze'
            WHEN completed_orders <= 4 THEN 'Silver'
            ELSE 'Gold'
        END AS customer_segment
    FROM vw_customer_summary
) t
GROUP BY customer_segment
ORDER BY revenue DESC;




















