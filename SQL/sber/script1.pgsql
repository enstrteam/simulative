/*
 * Определить, как менялось пиковое значение по ежедневному количеству регистраций на платформе. 
 * Период Анализа:
 * Рассматриваем период с 01.01.2022 и последующие 110 дней.
 * Таблица users:
 * dt: Какая дата.
 * cnt: Сколько людей зарегистрировалось в этот день.
 * max_cnt: Нарастающее значение максимума регистраций.
 * diff: Разница между текущим значением и актуальным максимумом.
 * Примечание: Дни без регистраций мы тоже учитываем.
 */
with
    calendar as (
        select
            generate_series(
                '2022-01-01'::timestamp,
                (date ('2022-01-01') + 110)::timestamp,
                '1 day'
            ) as dt
    ),
    table_cnt as (
        select
            date (date_joined) as dt,
            count(*) as cnt
        from
            users
        group by
            dt
        having
            date (date_joined) between '2022-01-01' and date  ('2022-01-01') + 110
        order by
            dt
    ),
    calendar_join as (
        select
            calendar.dt,
            coalesce(table_cnt.cnt, 0) as cnt
        from
            calendar
            left join table_cnt on calendar.dt = table_cnt.dt
    ),
    table_max_cnt as (
        select
            dt,
            cnt,
            max(cnt) over (
                order by
                    dt rows between unbounded preceding
                    and current row
            ) as max_cnt
        from
            calendar_join
    )
select
    *,
    cnt - max_cnt as diff
from
    table_max_cnt