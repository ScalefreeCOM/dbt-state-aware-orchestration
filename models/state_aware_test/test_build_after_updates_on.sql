{{
  config(
  materialized='table')
  
}}


SELECT *EXCEPT(ldts,rsrc,o_custkey)
FROM {{ ref('customer_h') }}
JOIN {{ ref('order_h') }} ON 1=1
JOIN {{ ref('nation_h') }} ON 1=1