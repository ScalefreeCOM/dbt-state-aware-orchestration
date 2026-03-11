{{
  config(
    freshness={
      "build_after": {
        "updates_on": "all"
      }
    },
  materialized='table')
  
}}


SELECT *EXCEPT(ldts,rsrc)
FROM {{ ref('customer_h') }}
JOIN {{ ref('order_h') }} ON 1=1
JOIN {{ ref('nation_h') }} ON 1=1