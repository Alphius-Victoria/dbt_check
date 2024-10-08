{{ config(
    tags=['stg_models']
) }}

with base as (

    select * 
    from {{ ref('stg_netsuite2__vendor_categories_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_netsuite2__vendor_categories_tmp')),
                staging_columns=get_vendorcategory_columns()
            )
        }}
    from base
),

final as (
    
    select
        id as vendor_category_id,
        name,
        _fivetran_synced
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
