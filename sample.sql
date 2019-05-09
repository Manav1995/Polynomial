--Updated at: 04/04/19
--check statuses of columns different orders with ivan 
--check with esteban the order rank process
drop table master.order;
create table master.order as
with order_item as (
 	select 
 		order_id,
 		sum(quantity) as order_item_count,
 		sum(total_price) as basket_size,
 		max(case when trial_days >=1 then 1 else 0 end) as is_trial_order
 	from ods_production.order_item i
 	group by 1)
select distinct 
	o.order_id, 
    o.customer_id, 
    o.store_id, 
    o.created_date, 
    o.submitted_date, 
    o.updated_date, 
    o.approved_date, 
    o.canceled_date, 
    o.acquisition_date, 
    o.status, 
    o.order_rank, 
    o.total_orders, 
    o.cancellation_reason, 
    o.declined_reason, 
    o.order_value, 
    o.voucher_code::varchar(510), 
    o.voucher_type::varchar(510), 
    o.voucher_value::varchar(510), 
    o.voucher_discount, 
    o.is_in_salesforce, 
    o.store_type, 
	r.new_recurring,
	r.retention_group,
	m.marketing_channel,
	m.marketing_campaign,
	m.devicecategory as device,
	st.store_name::varchar(510),
	st.store_label,
	st.store_short,
	oi.order_item_count,
	oi.basket_size,
	oi.is_trial_order,
    1 as cart_orders,
    CASE
     WHEN o.status in ('CART') THEN 0
      ELSE 1
     END AS address_orders,
                CASE
                    WHEN o.status in ('ADDRESS','CART') THEN 0
                    ELSE 1
                END AS payment_orders,               
				CASE
      				WHEN o.is_in_salesforce=1 THEN 1
      				ELSE 0
     				END AS completed_orders,
    			CASE
      				WHEN o.status = 'DECLINED' THEN 1
      				ELSE 0
     				END AS declined_orders,
    			CASE
       				WHEN o.status in ('FAILED FIRST PAYMENT','FAILED_FIRST_PAYMENT') THEN 1
                    ELSE 0
                	END AS failed_first_payment_orders,
                CASE
                    WHEN o.status = 'CANCELLED' THEN 1
                    ELSE 0
                END AS cancelled_orders,
                CASE
                    WHEN o.status = 'PAID' THEN 1
                    ELSE 0
                END AS paid_orders,
                cs.current_subscription_limit,
                cs.burgel_risk_category,
                cs.schufa_class,
                os.order_scoring_comments as scoring_decision,
                c.customer_type
from ods_production."order" o 
left join ods_production.customer c 
 on c.customer_id=o.customer_id
left join ods_production.order_retention_group r 
 on r.order_id=o.order_id
left join ods_production.order_marketing_channel m 
 on o.order_id = m.order_id
left join ods_production.customer_scoring cs 
 on cs.customer_id=o.customer_id
 left join ods_production.order_scoring os 
 on os.order_id=o.order_id
left join ods_production.store st on st.id=o.store_id
left join order_item oi on oi.order_id=o.order_id
where o.order_id is not null;
 
