-- Как оценка в отзыве зависит от того, насколько заказ опоздал
select
    case
        when delay_days <= -7 then '1. раньше срока на 7+ дн.'
        when delay_days <=  0 then '2. в срок'
        when delay_days <=  3 then '3. опоздание 1-3 дн.'
        when delay_days <=  7 then '4. опоздание 4-7 дн.'
        when delay_days <= 14 then '5. опоздание 8-14 дн.'
        else                       '6. опоздание 15+ дн.'
    end                                              as delay_group,
    count(*)                                         as orders,
    round(avg(review_score), 2)                      as avg_score,
    round(100.0 * avg((review_score <= 2)::int), 1)  as bad_review_pct
from orders_flat
where review_score is not null
group by 1
order by 1;
