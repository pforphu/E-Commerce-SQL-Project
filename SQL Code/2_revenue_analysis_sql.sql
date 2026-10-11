use project01;
 -- revenue analysis 
with base_cte as 
(select count(distinct case when event_type = 'page_view' then user_id end) as visitor, 
 count(distinct case when event_type = 'purchase' then user_id end) as buyer, 
 count(case when event_type = 'purchase' then 1 end) as total_order, 
 round(sum(case when event_type = 'purchase' then amount end),2) as revenue 
 from user_events) 
select visitor, buyer, total_order, concat(revenue,' $') as revenue , 
concat(round(buyer/visitor *100,2), ' %') as avg_convert_rate, 
concat(round(revenue/total_order,2), ' $') as avg_revenue, 
concat(round(revenue/buyer,2), ' $') as avg_revenue_buyer
from base_cte;