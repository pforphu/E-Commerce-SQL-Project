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
