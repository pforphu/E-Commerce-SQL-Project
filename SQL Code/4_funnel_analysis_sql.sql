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
