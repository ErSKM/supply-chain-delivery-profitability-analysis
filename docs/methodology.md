# Methodology and metric definitions

## Data grain and model

The imported source contains 180,519 order-item rows and 65,752 distinct `order_id` values. `fact_orders` retains one row per source order item; the table name is historical and does not mean one row per order. Customer and product attributes are separated into `dim_customers` and `dim_products`.

For delivery metrics, the scripts first reduce rows to one record per order using the validated order-level shipping mode, delivery status, actual shipping days, and scheduled shipping days. This prevents orders with multiple items from being counted as multiple orders.

## Definitions

- **Eligible orders:** distinct orders where `delivery_status <> 'Shipping canceled'`.
- **Late orders:** eligible orders with `delivery_status = 'Late delivery'`.
- **Late order rate:** late eligible orders divided by eligible orders.
- **Average delay among late orders:** average of `actual shipping days - scheduled shipping days` for late orders only.
- **Average schedule gap:** average of `actual shipping days - scheduled shipping days` across eligible orders. Positive values mean actual shipping took longer than scheduled; negative values mean it was early.
- **Sales:** sum of the source `sales` value, retained in the fact table as `sales_amount`.
- **Reported profit:** sum of `benefit_per_order`; margin is reported profit divided by sales. This is the dataset's measure, not an independently verified accounting result.
- **Customer-state sales:** sales grouped by the customer's state, not the order's destination state.

## Validation performed

- Confirmed the staging import contains 180,519 rows, 180,519 distinct order-item IDs, and 65,752 distinct orders, with no missing item IDs.
- Confirmed shipping mode, delivery status, actual shipping days, and scheduled shipping days are consistent within each order for the checks performed.
- Compared `benefit_per_order` and `order_profit_per_order`; the imported values matched in the row-level audit.
- Reconciled sales and reported-profit sums from item rows to order-grouped rollups; the audited totals matched.

## Limitations

- Delivery differences show where to investigate, not why delays occurred. Carrier, warehouse, and process-level causes cannot be isolated from the available fields.
- The analysis is descriptive and does not establish that shipping mode caused late delivery.
- The state concentration finding is based on customer location. It is not a map of shipping destinations.
- Margin describes the source profit field in this dataset and should not be presented as audited company net income.
