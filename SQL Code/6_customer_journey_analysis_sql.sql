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
 
 

