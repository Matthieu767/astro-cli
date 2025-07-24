{{ config(materialized='table') }}

select 
    ba.item_id,
    sa.attribute_id,
    ba.attribute_value as value,
    ba.partition_date
from {{ ref('bronze_attributes') }} ba
join {{ ref('silver_attributes') }} sa 
    on ba.attribute_name = sa.attribute_name 
    and ba.partition_date = sa.partition_date 