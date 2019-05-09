drop table if exists master.asset;
create table master.asset as
with fso as (
  SELECT DISTINCT 
    a.asset_id,
    s.order_id,
    COALESCE(st.id,null) AS first_allocation_store_id,
  	COALESCE(st.store_name, 'NOT AVAILABLE'::character varying) AS first_allocation_store_name,
    COALESCE(st.store_label, 'NOT AVAILABLE'::character varying::text) AS first_allocation_store_label
   FROM ods_production.allocation a
     LEFT JOIN ods_production.subscription s 
      ON a.subscription_id::text = s.subscription_id::text
     LEFT JOIN ods_production.store st ON s.store_id = st.id
  WHERE a.rank_allocations_per_asset = 1
)
,spv_prep as (select * from ods_production.spv_report)
, spv as (
select distinct 
asset_id, 
first_value(final_price) 
 over (partition by asset_id order by reporting_date desc
 rows unbounded preceding) as last_valuation,
first_value(reporting_date) 
 over (partition by asset_id order by reporting_date desc
 rows unbounded preceding) as last_valuation_report_date
from spv_prep)
SELECT distinct
	 a.asset_id::VARCHAR(18)
    ,a.customer_id
    ,a.subscription_id
	,a.created_date::TIMESTAMP WITHOUT TIME ZONE as created_at
	,a.updated_date::TIMESTAMP WITHOUT TIME ZONE as updated_At
 	,coalesce(a.asset_allocation_id,aa1.allocation_id)::VARCHAR(18) as asset_allocation_id
 	,aa1.allocation_sf_id::VARCHAR(80) as asset_allocation_sf_id
 	,a.warehouse::VARCHAR(255)
 	,a.capital_source_name::VARCHAR(80)
 	,a.supplier::VARCHAR(65535)
 	,coalesce(fso.first_allocation_store_label,'never allocated')::VARCHAR(30) as first_allocation_store	
    ,coalesce(fso.first_allocation_store_name,'never allocated')::VARCHAR(30) as first_allocation_store_name	
    ,a.serial_number::VARCHAR(80)
	,a.product_ean::VARCHAR(65535) as ean
 	,a.product_sku::VARCHAR(255)
 	,variant_sku::VARCHAR(65535)
 	,a.product_name::VARCHAR(510)
 	,a.category_name::VARCHAR(65535)
 	,a.subcategory_name::VARCHAR(65535)
 	,a.brand::VARCHAR(65535)
    ,a.invoice_url
 	,coalesce(aa1.total_allocations_per_asset,0)::BIGINT AS total_allocations_per_asset
 	,a.purchased_date::DATE
    ,a.months_since_purchase::INTEGER
    ,a.days_since_purchase::INTEGER
 	,a.amount_rrp::DOUBLE PRECISION as amount_rrp
 	,a.initial_price::DOUBLE PRECISION
 	,mv.residual_value_market_price::DOUBLE PRECISION
    ,mv.average_of_sources_on_condition_this_month
    ,mv.average_of_sources_on_condition_last_available_price
    ,a.sold_price
 	,a.sold_date::DATE
 	,a.currency::VARCHAR(255)
 	,a.asset_status_original::VARCHAR(255)
 	,aa2.asset_status_new::VARCHAR(30) as asset_status_new
 	,aa2.asset_status_detailed::VARCHAR(255)
 	,aa2.last_allocation_days_in_stock::DOUBLE PRECISION
 	,last_allocation_dpd::INTEGER
 	,ac.subscription_revenue_paid::DOUBLE PRECISION as subscription_revenue
    ,ac.subscription_revenue_due::DOUBLE PRECISION as subscription_revenue_due
    ,ac.subscription_revenue_paid_last_month::DOUBLE PRECISION as subscription_revenue_last_month
 	,ac.avg_subscription_amount::DOUBLE PRECISION
 	,ac.max_subscription_amount::DOUBLE PRECISION
 	,ac.sub_payments_due::BIGINT as payments_due
    ,ac.last_payment_amount_due::BIGINT as last_payment_amount_due
    ,ac.last_payment_amount_paid::BIGINT as last_payment_amount_paid
 	,ac.sub_payments_paid::BIGINT as payments_paid
 	,ac.repair_cost_paid::DOUBLE PRECISION
 	,ac.customer_bought_paid::DOUBLE PRECISION
 	,ac.grover_sold_paid::DOUBLE PRECISION
 	,ac.additional_charge_paid::DOUBLE PRECISION
 	,ad.delivered_allocations::BIGINT
 	,ad.returned_allocations::BIGINT
 	,ac.max_paid_date::TIMESTAMP WITHOUT TIME ZONE	
    ,a.office_or_sponsorships::VARCHAR(22)
    ,spv.last_valuation::DOUBLE PRECISION as last_market_valuation
    ,spv.last_valuation_report_date::TIMESTAMP WITHOUT TIME ZONE
    ,greatest(a.initial_price-(((a.months_since_purchase  )-1)*1::decimal/36::decimal*a.initial_price),0)::DOUBLE PRECISION as asset_value_linear_depr
    ,a.shipping_country
FROM ods_production.asset a
LEFT JOIN ods_production.allocation aa1 
 ON aa1.asset_id=a.asset_id 
 and (aa1.is_last_allocation_per_asset
  OR aa1.allocation_id IS NULL)
--	left join ods_production.product p on a.product_sku=p.product_sku
	left join ods_production.asset_allocation_history ad on ad.asset_id=a.asset_id
	LEFT JOIN ods_production.asset_last_allocation_details aa2 ON aa2.asset_id=a.asset_id
	left join ods_production.asset_cashflow ac on ac.asset_id=a.asset_id	
	left join ods_production.asset_market_value mv  on mv.asset_id =a.asset_id
	left join fso on fso.asset_id=a.asset_id
    left join spv on spv.asset_id=a.asset_id
WHERE TRUE 
 AND a.asset_status_new <> 'NEVER PURCHASED';
