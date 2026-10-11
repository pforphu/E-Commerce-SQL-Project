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

-- define and count sale channel and different stages in dataset
select count(distinct case when event_type = 'page_view' then user_id end) as page_stage, 
	count(distinct case when event_type = 'add_to_cart' then user_id end) as cart_stage, 
    count(distinct case when event_type = 'checkout_start' then user_id end) as checkout_stage, 
    count(distinct case when event_type = 'payment_info' then user_id end) as payment_stage, 
    count(distinct case when event_type = 'purchase' then user_id end) as purchase_stage
    from user_events;
    

-- define the convert rate in each step 
with count_stage_cte as
(select count(distinct case when event_type = 'page_view' then user_id end) as page_stage, 
	count(distinct case when event_type = 'add_to_cart' then user_id end) as cart_stage, 
    count(distinct case when event_type = 'checkout_start' then user_id end) as checkout_stage, 
    count(distinct case when event_type = 'payment_info' then user_id end) as payment_stage, 
    count(distinct case when event_type = 'purchase' then user_id end) as purchase_stage
    from user_events)
select page_stage, cart_stage, 
-- convert from stage 2 divide stage 1 
concat(round(cart_stage/page_stage *100,2), ' %') as page_to_cart_rate,
checkout_stage,
-- convert from stage 3 divide stage 2
concat(round(checkout_stage/page_stage *100,2), ' %') as cart_to_checkout_rate, 
payment_stage,
-- convert from stage 4 divide stage 3
concat(round(payment_stage/checkout_stage*100,2), ' %') as checkout_to_pay_rate, 
purchase_stage,
-- convert from stage 5 divide stage 4
concat(round(purchase_stage/ payment_stage *100,2), ' %') as payment_to_purchase_rate, 
-- convert from stage 5 divid stage 1 to get overall convert rate 
concat(round(purchase_stage/page_stage *100,2), ' %') as overall_convert_rate 
from count_stage_cte;
-- 5000 visitors view page, 
-- 1553 added items to their cart
-- 1103 customers start to check out
-- 899 payment information
-- 826 customers complete a purchase


-- define and count traffic source from dataset
with traffic_cte as
(select traffic_source, 
count(distinct case when event_type = 'page_view' then user_id end) as views, 
count(distinct case when event_type = 'add_to_cart' then user_id end) as cart, 
count(distinct case when event_type = 'purchase' then user_id end) as purchase 
from user_events 
group by traffic_source)

select traffic_source,  views, cart, 
-- convert from cart divides views
concat(round(cart/views* 100,2), ' %') as views_to_cart_rate, 
purchase,
-- convert from purhase divides cart
concat(round(purchase/cart * 100,2), ' %')  as cart_to_purchase_rate, 
-- convert from purhcase divides views
concat(round(purchase/views* 100,2), ' %') as overall_convert_rate
 from traffic_cte
 order by concat(round(purchase/views* 100,2), ' %') desc ;
 
 -- Email traffic performs the best, with the higehst views-to-cart (62%) and the strongest overall conversion (34%)
 -- Paid ads perform well, showing a second highest overall converstion rate (21.05%)
 -- Organic and Social demonstrate a less performative conversion rate with 16.83% and 6.93%, respectively 

 -- customers' stage journey 
 with time_journey_cte as
 (select user_id, 
 min(case when event_type = 'page_view' then event_date end) as view_time, 
 min(case when event_type = 'add_to_cart' then event_date end) as cart_time, 
 min(case when event_type = 'purchase' then event_date end) as purchase_time
 from user_events
 group by user_id
 -- set conditions purchase_time is not null becasue this is the last step of customers' journey, if purhcase_time is not null, cart_time and view_time will be not null 
 having  min(case when event_type = 'purchase' then event_date end) is not null) 
 
 select count(*), 
 round(avg(timestampdiff(minute, view_time, cart_time)),2) as avg_view_to_cart_time, 
 round(avg(timestampdiff(minute, cart_time, purchase_time)),2) as avg_cart_to_purchase_time, 
 round(avg(timestampdiff(minute, view_time, purchase_time)),2) as avg_total_journey_time
 from time_journey_cte;
 
 

