-- Доля опоздавших заказов по месяцам покупки
select
    purchase_month,
    count(*)                                   as orders,
    round(100.0 * avg(is_late::int), 1)        as late_pct
from orders_flat
group by 1
order by 1;
