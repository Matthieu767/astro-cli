{{ config(materialized='table') }}

select 
    id,
    title,
    description,
    partition_date
from {{ ref('silver_items') }} 