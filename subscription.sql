drop table master.subscription;
create table master.subscription as
SELECT DISTINCT
 	s.subscription_id,
 	s.subscription_name as subscription_sf_id,
 	s.created_date,
    s.updated_date,
    s.start_date,
    s.rank_subscriptions,
    min(s.start_date) over (partition by s.customer_id) as first_subscription_start_date,
    s.subscriptions_per_customer,
 	s.customer_id,
    coalesce(c.customer_type,'normal_customer') as customer_type,
 	cust.customer_acquisition_cohort,
 	c.subscription_limit,
    s.order_id,
    st.store_name::varchar(510),
    st.store_label,
    s.status,
    s.variant_sku,
    s.allocation_status,
    s.replacement_attempts,
    sa.allocated_assets,
    sa.delivered_assets,
    sa.returned_packages,
    sa.returned_assets,
    COALESCE(sa.outstanding_assets,0) AS outstanding_assets,
    COALESCE(sa.outstanding_purchase_price,0) AS outstanding_asset_value,
    COALESCE(sa.outstanding_rrp,0) AS outstanding_rrp,
    s.first_asset_delivery_date,
    sa.last_return_shipment_at,
    s.subscription_plan,
    s.subscription_value AS monthly_subscription_payment,
    s.rental_period,
    s.subscription_value,
    s.committed_sub_value,
    sc.default_date as next_due_date,
    CASE
            WHEN s.status::text = 'ACTIVE'::text AND
            CASE
                WHEN (s.committed_sub_value::double precision - COALESCE(sc.subscription_revenue_paid, 0::numeric)::double precision) < s.subscription_value THEN 0::double precision
                ELSE s.committed_sub_value::double precision - COALESCE(sc.subscription_revenue_paid, 0::numeric)::double precision
            END = 0::double precision THEN s.subscription_value
            ELSE
            CASE
                WHEN (s.committed_sub_value::double precision - COALESCE(sc.subscription_revenue_paid, 0::numeric)::double precision) < s.subscription_value THEN 0::double precision
                ELSE s.committed_sub_value::double precision - COALESCE(sc.subscription_revenue_paid, 0::numeric)::double precision
            END
        END AS commited_sub_revenue_future,
    s.currency,
 	s.subscription_duration,
    case
 when status = 'CANCELLED' 
   then greatest(paid_subscriptions,1)
 when status = 'ACTIVE'
  then greatest(minimum_term_months,paid_subscriptions+1)
   end as effective_duration,
case
 when status = 'CANCELLED' 
   then null
 when status = 'ACTIVE'
  then greatest(minimum_term_months,paid_subscriptions+1)-paid_subscriptions
   end as outstanding_duration,
	sc.payment_count,
	sc.paid_subscriptions,
    sc.last_valid_payment_category,
    sc.dpd,
	sc.subscription_revenue_due,
	sc.subscription_revenue_paid,
    sc.outstanding_subscription_revenue,
	sc.subscription_revenue_refunded,
    sc.subscription_revenue_chargeback,
	sc.net_subscription_revenue_paid,
    s.cancellation_date,
    cr.cancellation_reason,
    cr.cancellation_reason_new,
    cr.cancellation_reason_churn,
    cr.is_widerruf,
    s.payment_method,
    s.debt_collection_handover_date,  
    s.dc_status::varchar(21),
    s.result_debt_collection_contact,
    sa.avg_asset_purchase_price,
    p.product_sku,
    p.product_name,
    p.category_name,
    p.subcategory_name,
    p.brand,
    nr.new_recurring,
    s.minimum_cancellation_date,
    asset_cashflow_from_old_subscriptions,
    exposure_to_default,
    case 
      when net_subscription_revenue_paid- (outstanding_rrp+3*monthly_subscription_payment)<=0 
   		or coalesce(outstanding_rrp,0) = 0 
     then null 
   else net_subscription_revenue_paid- (outstanding_rrp+3*monthly_subscription_payment) 
    end as mietkauf_amount_overpayment
   FROM ods_production.subscription s
     LEFT JOIN ods_production.store st 
      ON s.store_id = st.id
     LEFT JOIN ods_production.order_retention_group nr 
      ON nr.order_id = s.order_id
     LEFT JOIN ods_production.customer c 
      ON c.customer_id = s.customer_id
     LEFT JOIN ods_production.subscription_cashflow sc 
      ON s.subscription_id = sc.subscription_id
     LEFT JOIN ods_production.subscription_assets sa 
      ON s.subscription_id = sa.subscription_id
	 left join ods_production.subscription_cancellation_reason cr 
      on cr.subscription_id=s.subscription_id
	 left join ods_production.customer_acquisition_cohort cust 
      on cust.customer_id=s.customer_id
     left join ods_production.variant v 
      on v.variant_sku=s.variant_sku
     left join ods_production.product p
      on p.product_id=v.product_id
   ;
