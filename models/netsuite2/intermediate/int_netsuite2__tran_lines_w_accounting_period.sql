{{
  config(
    tags= ['intermediate']
  )
}}

with transactions as (
    select * 
    from {{ ref('stg_netsuite2__transactions') }}
), 

transaction_lines as (
    select * 
    from {{ ref('int_netsuite2__transaction_lines') }}
),

transaction_lines_w_accounting_period as ( -- transaction line totals, by accounts, accounting period and subsidiary
  select
    transaction_lines.transaction_id,
    transaction_lines.transaction_line_id,
    transaction_lines.subsidiary_id,
    transaction_lines.account_id,

    {% if var('netsuite2__multibook_accounting_enabled', false) %}
    transaction_lines.accounting_book_id,
    transaction_lines.accounting_book_name,
    {% endif %}
    
    transactions.accounting_period_id as transaction_accounting_period_id,
    coalesce(transaction_lines.amount, 0) as unconverted_amount,
    transactions._fivetran_synced
  from transaction_lines

  join transactions on transactions.transaction_id = transaction_lines.transaction_id

  where lower(transactions.transaction_type) != 'revenue arrangement'
    and transaction_lines.is_posting
)

select * 
from transaction_lines_w_accounting_period