-- Compact validation queries used to check the imported source and metric grain.
USE supply_chain_db;

-- Source row, order-item, and order counts.
SELECT
    COUNT(*) AS staging_rows,
    COUNT(DISTINCT order_item_id) AS distinct_order_items,
    COUNT(DISTINCT order_id) AS distinct_orders,
    SUM(order_item_id IS NULL OR TRIM(order_item_id) = '') AS missing_order_item_ids
FROM staging_supply_chain;

-- Confirm each order has one shipping mode/status/day pair before order-level aggregation.
SELECT COUNT(*) AS orders_with_multiple_shipping_or_delivery_values
FROM (
    SELECT order_id
    FROM staging_supply_chain
    GROUP BY order_id
    HAVING COUNT(DISTINCT shipping_mode) > 1
        OR COUNT(DISTINCT delivery_status) > 1
        OR COUNT(DISTINCT CAST(days_for_shipping_real AS SIGNED)) > 1
        OR COUNT(DISTINCT CAST(days_for_shipment_scheduled AS SIGNED)) > 1
) AS order_checks;

-- Confirm the two source profit fields agree row by row.
SELECT
    COUNT(*) AS source_rows,
    SUM(CAST(benefit_per_order AS DECIMAL(12,2)) =
        CAST(order_profit_per_order AS DECIMAL(12,2))) AS rows_with_matching_profit_fields,
    SUM(CAST(benefit_per_order AS DECIMAL(12,2)) <>
        CAST(order_profit_per_order AS DECIMAL(12,2))) AS rows_with_different_profit_fields
FROM staging_supply_chain;
