// KPI 1 = Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics

SELECT kpi1.day_end,
       CONCAT(ROUND(kpi1.total_payment / total.total_sum * 100, 2), '%') AS percentage_payment_values
FROM
  (SELECT ord.day_end,
          SUM(pmt.payment_value) AS total_payment
   FROM olist_order_payments_dataset AS pmt
   JOIN
     (SELECT DISTINCT order_id,
                      CASE
                        WHEN WEEKDAY(order_purchase_timestamp) IN (5, 6) THEN "Weekend"
                        ELSE "Weekday"
                      END AS Day_end
      FROM olist_orders_dataset) AS ord ON ord.order_id = pmt.order_id
   GROUP BY ord.day_end) AS kpi1,
  (SELECT SUM(payment_value) AS total_sum
   FROM olist_order_payments_dataset) AS total;

// KPI 2 = Number of Orders with review score 5 and payment type as credit card.//

select 
count(pmt.order_id) as Total_orders 
from olist_order_payments_dataset pmt
join olist_order_reviews_dataset rev on pmt.order_id = rev.order_id
where 
review_score = 5 and 
payment_type = "credit_card"; 

// KPI 3 = Average number of days taken for order_delivered_customer_date for pet_shop

select 
prod.product_category_name,
round(avg(datediff(ord.order_delivered_customer_date , ord.order_purchase_timestamp)) , 0) as Avg_delivery_days
from olist_orders_dataset ord
join
(select product_id ,order_id , product_category_name
from olist_products_dataset 
join olist_order_items_dataset using(product_id)) as prod
on ord.order_id = prod.order_id
where prod.product_category_name = "pet_shop"
group by prod.product_category_name;

// KPI 4 = Average price and payment values from customers of sao paulo city

with orderitemAvg as(
select round(avg(item.Price)) as avg_order_item_price
from olist_order_items_dataset item
join olist_orders_dataset ord on item.order_id = ord.order_id
join olist_customers_dataset cust on ord.customer_id = cust.customer_id
where cust.customer_city = "Sao Paulo"
)

select 
(select avg_order_item_price from orderitemAvg) as avg_order_item_price,
 round(avg(pmt.payment_value)) as avg_payment_value
 from olist_order_payments_dataset pmt
 join olist_orders_dataset ord on pmt.order_id = ord.order_id
 join olist_customers_dataset cust on ord.customer_id = cust.customer_id
 where cust.customer_city = "Sao Paulo";

// KPI 5 = Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

 select 
 rew.review_score,
 round(avg(datediff(ord.order_delivered_customer_date , ord.order_purchase_timestamp)), 0) as "Avg Shipping Days"
 from olist_orders_dataset ord
 join olist_order_reviews_dataset rew on ord.order_id = rew.order_id
 group by rew.review_score
 order by rew.review_score;
