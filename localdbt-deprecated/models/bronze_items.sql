{{ config(materialized='table') }}

select 
    id,
    title,
    description,
    '{{ var("partition_date") }}' as partition_date
from bronze_items_source 