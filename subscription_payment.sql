drop table master.subscription_payment;
create table master.subscription_payment as
SELECT 
	sp.subscription_payment_id AS payment_id,
    sp.subscription_payment_name as payment_sfid,
    sp.customer_id,
    c.customer_type,
    sp.order_id,
    sp.asset_id,
    a.brand,
    a.category_name,
    a.subcategory_name,
    sp.subscription_id,
    CASE WHEN coalesce(sa.delivered_assets,0) >0 IS NOT NULL THEN true ELSE false END AS asset_was_delivered,
    CASE WHEN coalesce(sa.outstanding_assets,0) = 0 THEN true ELSE false END AS asset_was_returned,     
    date_trunc('day',s.start_date) AS subscription_start_date,
    sp.payment_number,
    sp.due_date,
    sp.paid_date,
    sp.failed_date,
    sp.attempts_to_pay,
    sd.subscription_payment_category,
    case 
 when sc.last_valid_payment_category like ('%DEFAULT%') 
  and sc.last_valid_payment_category not like ('%RECOVERY%')
  AND asset_was_returned = false
  and sp.due_date > sd.next_due_date then 'non_performing'
 when sc.last_valid_payment_category like ('%DEFAULT%') 
  and sc.last_valid_payment_category not like ('%RECOVERY%')
  and sp.due_date = sd.next_due_date
  AND asset_was_returned = false
 then 'default_new'
 else 'not_default'
 end as default_new,
    sp.status,
	sp.payment_processor_message,
    sp.payment_method_details,
	sp.paid_status,
    sd.next_due_Date,
    sd.dpd,
    sp.payment_method_detailed,
    sp.currency,
    sp.amount_due,
    sp.amount_paid,
    sp.amount_subscription,
    sp.amount_shipment,
    sp.amount_voucher,
    sp.amount_discount,
    sp.amount_vat_tax,
    sp.amount_overdue_fee,
    sp.amount_sales_tax,
    SP.refund_amount AS AMOUNT_REFUND,
    SP.chargeback_amount as amount_chargeback,
    s.debt_collection_handover_date,
    s.result_debt_collection_contact,
    case  
		when sp.date_debt_collection_handover::date is not null and (sp.paid_date>sp.date_debt_collection_handover) then true
		else false
		end as is_dc_collections,
    sd.is_eligible_for_refund,
    s.subscription_plan,
    s.store_label, 
    s.store_name, 
    s.store_short,
    cs.burgel_risk_category
   FROM ods_production.payment_subscription sp
   	left join ods_production.payment_subscription_details sd 
     on sp.subscription_payment_id=sd.subscription_payment_id
    LEFT JOIN ods_production.customer c 
     ON c.customer_id = sp.customer_id    
    LEFT JOIN ods_production.customer_scoring cs 
     ON cs.customer_id = sp.customer_id  
    left join ods_production.subscription s
     on s.subscription_id=sp.subscription_id
    LEFT JOIN ods_production.subscription_assets sa 
     ON s.subscription_id = sa.subscription_id
    left join ods_production.subscription_cashflow sc 
     on sc.subscription_id=sp.subscription_id
    left join ods_production.asset a on a.asset_id=sp.asset_id
 WHERE true 
 AND sp.status::text <> 'CANCELLED'::text 
 AND (sp.allocation_id IS NOT NULL OR sp.subscription_id IS NOT NULL)
  ORDER BY sp.subscription_id, sp.payment_number;

