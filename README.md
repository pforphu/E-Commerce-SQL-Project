# E-Commerce-SQL-Project'
## 🧾Project Overview
The dataset includes user activities such as page views, add‑to‑cart actions, checkout steps, payment information, completed purchases, traffic sources, timestamps, and transaction amounts.

The goal of this project is to understand how customers move through the platform, identify where drop‑offs happen, and measure how effectively the platform converts visitors into buyers. By analyzing conversion rates, customer journey time, and revenue metrics, the project provides insights that can help improve user experience and increase business performance.


## 🎯Project Obectives
- 📈 Measure the conversion rate at each stage of the e‑commerce funnel.
- 🔍 Identify stages where the platform loses potential customers.
- ⏱️ Analyze customer journey time from first interaction to final purchase.
- 🌐 Compare performance across different traffic sources (social, organic, paid ads, email).


## 🧾Dataset Description 
- The dataset contains 5000 records from Platform

### 📘 Data Dictionary

| Column Name     | Data Type |
|-----------------|------------|
| event_id        | INTEGER    |
| user_id         | INTEGER    |
| event_type      | VARCHAR    |
| event_date      | DATETIME   |
| product_id      | INTEGER    |
| amount          | DECIMAL    |
| traffic_source  | VARCHAR    |


## SQL Tools Applied 
- SQL (MySQL)
- Microsoft SQL Server (SSMS)

## 📈SQL Analysis 
- Revenue Analysis
- Funnel Analysis: page view → add to cart → checkout → payment → purchase.
- Traffic Source Performance: how different marketing channels contribute to conversions.
- Customer Journey Timing: average time between key actions (view → cart → purchase).

## 📈SQL Queries 

### ❓Q1. Finding platform's revenue and conversion metrics. 
``` sql
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
from base_cte

```
<img width="722" height="92" alt="Q1 " src="https://github.com/user-attachments/assets/f1023fac-09e7-4546-8deb-53338e001d79" />

### ❓Q2. How many customers reach each stage of the e‑commerce funnel
```sql
select count(distinct case when event_type = 'page_view' then user_id end) as page_stage, 
count(distinct case when event_type = 'add_to_cart' then user_id end) as cart_stage, 
count(distinct case when event_type = 'checkout_start' then user_id end) as checkout_stage, 
count(distinct case when event_type = 'payment_info' then user_id end) as payment_stage, 
count(distinct case when event_type = 'purchase' then user_id end) as purchase_stage
from user_events;

-- 5000 visitors view page
-- 1553 added items to their cart 
-- 1103 customers start to check out
-- 899 payment information
-- 826 customers complete a purchase
```
<img width="576" height="82" alt="Q2" src="https://github.com/user-attachments/assets/f6cef394-a36b-4872-9279-41bf61e52727" />

### ❓Q3. what are the conversion rates between those stages?
```sql
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


```
<img width="1357" height="101" alt="Q3" src="https://github.com/user-attachments/assets/cadb22e4-ec9e-4c44-aae8-4b9d567dbfa3" />

### ❓Q4. What are the conversion rates for each traffic source across the e‑commerce funnel?
``` sql
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
```
<img width="767" height="125" alt="Q4" src="https://github.com/user-attachments/assets/14ff8dd5-3f20-47ed-8d7d-f910e1ca0da3" />


### ❓Q5. How long does it take for customer journey from view to complete a purchase?
``` sql
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

-- Customers usually took approximately 25 minutes from first view to final purchase

```
<img width="625" height="77" alt="Q5" src="https://github.com/user-attachments/assets/763fb5ab-c195-4b6f-8456-5764d3bf46d2" />

## 🔑Key findings: 
- Most customer drop‑off happens between viewing a product and starting checkout. Simplifying these steps or adding AI‑based guidance could improve conversion.
- Email traffic performs the best, with the highest view‑to‑cart rate (62%) and strongest overall conversion (34%).
- Paid ads also perform well, delivering the second‑highest overall conversion (21%).
- Organic and social traffic convert poorly, at 16.83% and 6.93% respectively.
- Customers who complete a purchase typically take around 25 minutes from first view to final checkout.

## 🛠️Recommendations: 
- Simplify the checkout flow: Reduce unnecessary steps or form fields to minimize drop‑off 
- Prioritizing in free channels, especially in Email Marketing, following by organic and social engagement to maximize revenue. Paid ads are the lastly option for considering because of decreasing revenue when company needs to allocate budget for advertising effectively
- Provide real‑time guidance during browsing: Implementing AI‑based product recommendations or assistance can help users move smoothly from viewing to purchasing.
  
## 🧾Conclusion: 
The results highlight where customers drop off, which channels convert best, and how the journey can be optimized to increase overall conversions.
