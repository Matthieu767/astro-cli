{{ config(materialized='table') }}

select 
    row_number() over (order by attribute_name) as attribute_id,
    attribute_name,
    partition_date
from (
    select distinct 
        attribute_name,
        partition_date
    from {{ ref('bronze_attributes') }}
) 