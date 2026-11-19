-- Сколько продавцов дают половину всех поздних передач в доставку
with by_seller as (
    select
        seller_id,
        count(*)                              as orders,
        sum(seller_handover_late::int)        as late_handovers
    from orders_flat
    where sellers_cnt = 1
    group by seller_id
),
ranked as (
    select
        *,
        row_number() over (order by late_handovers desc)                          as rnk,
        sum(late_handovers) over (order by late_handovers desc
                                  rows between unbounded preceding and current row)
            / sum(late_handovers) over ()                                          as cum_share
    from by_seller
)
select
    min(rnk)                                              as sellers_needed,
    (select count(*) from by_seller)                      as sellers_total,
    round(100.0 * min(rnk) / (select count(*) from by_seller), 1) as sellers_pct
from ranked
where cum_share >= 0.5;
