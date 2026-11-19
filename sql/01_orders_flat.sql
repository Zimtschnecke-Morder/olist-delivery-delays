-- Одна строка = один доставленный заказ.
-- Сюда собрано всё, что нужно для анализа опозданий:
-- сроки, оценка из отзыва, регион покупателя, вовремя ли продавец передал заказ в доставку.

create or replace table orders_flat as
with items as (
    select
        order_id,
        count(*)                     as items_cnt,
        sum(price)                   as items_value,
        sum(freight_value)           as freight_value,
        max(shipping_limit_date)     as shipping_limit_date,  -- крайний срок передачи в доставку
        count(distinct seller_id)    as sellers_cnt,
        any_value(seller_id)         as seller_id
    from order_items
    group by order_id
),
reviews as (
    -- у небольшой части заказов несколько отзывов, берём последний
    select order_id, review_score
    from order_reviews
    qualify row_number() over (partition by order_id order by review_answer_timestamp desc) = 1
)
select
    o.order_id,
    c.customer_unique_id,
    c.customer_state,
    s.seller_state,
    i.seller_id,
    i.sellers_cnt,
    i.items_value,
    i.freight_value,
    o.order_purchase_timestamp                                               as purchased_at,
    date_trunc('month', o.order_purchase_timestamp)                          as purchase_month,
    date_diff('day', o.order_purchase_timestamp, o.order_estimated_delivery_date) as promised_days,
    date_diff('day', o.order_purchase_timestamp, o.order_delivered_customer_date) as actual_days,
    date_diff('day', o.order_estimated_delivery_date, o.order_delivered_customer_date) as delay_days,
    o.order_delivered_customer_date > o.order_estimated_delivery_date        as is_late,
    o.order_delivered_carrier_date  > i.shipping_limit_date                  as seller_handover_late,
    r.review_score
from orders o
join customers c using (customer_id)
join items i     using (order_id)
left join sellers s on s.seller_id = i.seller_id
left join reviews r using (order_id)
where o.order_status = 'delivered'
  and o.order_delivered_customer_date is not null
  -- в сентябре 2016 и сентябре-октябре 2018 единичные заказы, это хвосты выгрузки
  and o.order_purchase_timestamp >= '2017-01-01'
  and o.order_purchase_timestamp <  '2018-09-01';
