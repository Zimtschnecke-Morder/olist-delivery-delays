-- Вернулся ли покупатель после первого заказа, в зависимости от того, опоздал ли первый заказ.
-- Берём только первые заказы до марта 2018, чтобы у каждого было хотя бы полгода на повторную покупку.
with numbered as (
    select
        *,
        row_number() over (partition by customer_unique_id order by purchased_at) as order_num,
        count(*)     over (partition by customer_unique_id)                       as orders_total
    from orders_flat
)
select
    is_late                                         as first_order_late,
    count(*)                                        as customers,
    sum((orders_total > 1)::int)                    as returned,
    round(100.0 * avg((orders_total > 1)::int), 2)  as returned_pct
from numbered
where order_num = 1
  and purchased_at < '2018-03-01'
group by 1
order by 1;
