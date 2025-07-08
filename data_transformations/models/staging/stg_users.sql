-- models/staging/stg_users.sql
{{ config(materialized='view') }}

select
    id as user_id,
    username,
    email,
    created_at,
    updated_at
from {{ source('public', 'users') }}
