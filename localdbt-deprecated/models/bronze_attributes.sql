{{ config(materialized='table') }}

select 
    item_id,
    attribute_name,
    attribute_value,
    '{{ var("partition_date") }}' as partition_date
from bronze_attributes_source 