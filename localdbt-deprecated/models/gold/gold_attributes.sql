{{ config(materialized='table') }}

select 
    attribute_id,
    attribute_name,
    partition_date
from {{ ref('silver_attributes') }} 