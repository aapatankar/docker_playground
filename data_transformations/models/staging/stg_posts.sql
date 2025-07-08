-- models/staging/stg_posts.sql
{{ config(materialized='view') }}

select
    id as post_id,
    user_id,
    title,
    content,
    created_at,
    updated_at
from {{ source('public', 'posts') }}
