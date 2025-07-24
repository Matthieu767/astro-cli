{{ config(materialized='table') }}

select 
    item_id,
    attribute_id,
    value,
    partition_date
from {{ ref('silver_values') }} 