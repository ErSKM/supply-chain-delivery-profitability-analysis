-- Delivery reliability metrics at order grain.
-- fact_orders contains order-item rows, so aggregate to one row per order first.
USE supply_chain_db;

WITH per_order AS (
    SELECT
        order_id,
        MAX(shipping_mode) AS shipping_mode,
        MAX(delivery_status) AS delivery_status,
        MAX(days_for_shipping_real) AS actual_days,
        MAX(days_for_shipment_scheduled) AS scheduled_days
    FROM fact_orders
    GROUP BY order_id
)
SELECT
    shipping_mode,
    COUNT(*) AS eligible_orders,
    SUM(delivery_status = 'Late delivery') AS late_orders,
    ROUND(100.0 * SUM(delivery_status = 'Late delivery') / COUNT(*), 2) AS late_order_rate_pct,
    ROUND(AVG(CASE WHEN delivery_status = 'Late delivery'
                   THEN actual_days - scheduled_days END), 2) AS avg_delay_days_when_late,
    ROUND(AVG(actual_days - scheduled_days), 2) AS avg_schedule_gap_days
FROM per_order
WHERE delivery_status <> 'Shipping canceled'
GROUP BY shipping_mode
ORDER BY late_order_rate_pct DESC;
