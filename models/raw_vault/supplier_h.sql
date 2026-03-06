{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
    stg_supplier:
        rsrc_static: 'TPC_H_SF1.Supplier'
    stg_partsupp:
        bk_columns: ps_suppkey
        rsrc_static: 'TPC_H_SF1.Partsupp'
    stg_lineitem:
        bk_columns: l_suppkey
        rsrc_static: 'TPC_H_SF1.LineItem'
hashkey: hk_supplier_h
business_keys: s_suppkey
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}