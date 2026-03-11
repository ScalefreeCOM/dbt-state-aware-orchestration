{{
  config(
    freshness={
      "build_after": {
        "count": 1,
        "period": "hour",
        "updates_on": "all"
      }
    }
  )
}}


SELECT *EXCEPT(ldts,rsrc)
FROM {{ ref('customer_h') }}
JOIN {{ ref('order_h') }} ON 1=1
JOIN {{ ref('nation_h') }} ON 1=1