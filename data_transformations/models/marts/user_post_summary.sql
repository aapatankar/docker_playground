-- models/marts/user_post_summary.sql
{{ config(materialized='table') }}

select
    u.user_id,
    u.username,
    u.email,
    count(p.post_id) as total_posts,
    min(p.created_at) as first_post_date,
    max(p.created_at) as latest_post_date,
    u.created_at as user_created_at
from {{ ref('stg_users') }} u
left join {{ ref('stg_posts') }} p on u.user_id = p.user_id
group by 
    u.user_id,
    u.username,
    u.email,
    u.created_at
