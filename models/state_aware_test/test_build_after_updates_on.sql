{{
  config(
  materialized='table')
  
}}


SELECT *EXCEPT(ldts,rsrc), 'test' AS test
FROM {{ ref('customer_h') }}
JOIN {{ ref('order_h') }} ON 1=1
JOIN {{ ref('nation_h') }} ON 1=1