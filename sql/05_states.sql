-- Опоздания по штатам покупателя: обещанный срок, фактический срок и доля опозданий
select
    customer_state,
    count(*)                                   as orders,
    round(avg(promised_days), 1)               as promised_days,
    round(avg(actual_days), 1)                 as actual_days,
    round(100.0 * avg(is_late::int), 1)        as late_pct
from orders_flat
group by 1
having count(*) >= 300
order by late_pct desc;
