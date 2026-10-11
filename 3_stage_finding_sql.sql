
-- define and count sale channel and different stages in dataset
select count(distinct case when event_type = 'page_view' then user_id end) as page_stage, 
	count(distinct case when event_type = 'add_to_cart' then user_id end) as cart_stage, 
    count(distinct case when event_type = 'checkout_start' then user_id end) as checkout_stage, 
    count(distinct case when event_type = 'payment_info' then user_id end) as payment_stage, 
    count(distinct case when event_type = 'purchase' then user_id end) as purchase_stage
    from user_events;