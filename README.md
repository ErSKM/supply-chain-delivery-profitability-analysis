# Supply Chain Analytics: Delivery Reliability & Profitability

An end-to-end analytics case study using MySQL and Power BI to examine delivery reliability, product-category profitability, and customer-state sales for the DataCo Smart Supply Chain dataset.

## Business question

Where should an operations team investigate first when a large share of orders miss their scheduled shipping time, and how do product and customer-state results add business context?

This is a descriptive diagnosis. The dataset helps identify *where* performance differs; it does not identify the carrier, warehouse, or process cause.

## Executive summary

- **$36.78M** in sales and **$3.97M** in reported profit; overall reported profit margin is **10.78%**.
- **36,048 of 62,897 eligible orders were late (57.3%)**. Shipping-canceled orders are excluded from delivery-rate metrics.
- **First Class** had 9,602 of 9,602 eligible orders late (100%). **Second Class** had the highest late rate after First Class (80.0%) and the longest average delay among late orders (2.5 days). **Standard Class** contributed the greatest number of late orders (14,995), despite a 39.8% late rate.
- The five highest-margin categories shown on the overview are led by **Golf Bags & Carts (17.46%)**.
- **Puerto Rico accounts for about 38.5% of sales by customer state** in this dataset. This is a customer-location concentration, not a shipping-destination finding.

These figures describe the dataset and are not causal estimates or claims about a live company.

## Dashboard

The Power BI report has two pages:

1. **Performance Overview** — sales, reported profit, profit margin, top-five category margins, average schedule gap by shipping option, customer-state results, and key findings.
2. **Delivery Reliability** — eligible and late orders, late rates by shipping option, and average delay among late orders.

Open [`dashboard/Supply_Chain_Analytics_Dashboard.pbix`](dashboard/Supply_Chain_Analytics_Dashboard.pbix) in Power BI Desktop. The report was built against a local MySQL database named `supply_chain_db`; update the local source/credentials if your MySQL connection differs.

Screenshots can be added under `images/` after exporting each report page from Power BI.

## Repository layout

```text
.
├── dashboard/
│   └── Supply_Chain_Analytics_Dashboard.pbix
├── data/
│   └── README.md
├── docs/
│   └── methodology.md
├── images/
├── sql/
│   ├── 00_create_staging_table.sql
│   ├── 01_build_star_schema.sql
│   ├── 02_delivery_reliability.sql
│   ├── 03_category_profitability.sql
│   ├── 04_low_profit_customer_cities.sql
│   └── 05_data_quality_checks.sql
└── README.md
```

## Reproduce the analysis

1. Download the source dataset using the link in [`data/README.md`](data/README.md). Keep the raw CSV outside this repository.
2. Run `sql/00_create_staging_table.sql` in MySQL Workbench.
3. Import the source CSV into `supply_chain_db.staging_supply_chain` with the Workbench Table Data Import Wizard. The CSV is commonly distributed with Latin-1 text encoding. Map the columns to the staging table and omit `Customer Segment`, which is not used by this project.
4. Run `sql/01_build_star_schema.sql`. **This script drops and recreates the three modeled tables** (`dim_customers`, `dim_products`, and `fact_orders`). Keep the staging table loaded.
5. Run `sql/05_data_quality_checks.sql` to review row/order counts and source-field consistency.
6. Run the analysis scripts `02`–`04`, then open the PBIX report and refresh its MySQL source if needed.

## Tools

- MySQL / MySQL Workbench — staging, relational modeling, validation, and analytical SQL
- Power BI Desktop — measures, interactive visuals, and narrative dashboard

## Important interpretation notes

- The source has **180,519 order-item rows** and **65,752 distinct orders**. The SQL fact table is named `fact_orders`, but its rows are at order-item grain. Delivery metrics aggregate to one row per order before counting or averaging orders.
- **Eligible order** means a distinct order whose delivery status is not `Shipping canceled`.
- **Late order rate** = distinct late eligible orders ÷ distinct eligible orders.
- **Average delay among late orders** uses actual shipping days minus scheduled days, only for late orders.
- **Average schedule gap** = actual shipping days minus scheduled shipping days, averaged once per eligible order. Positive means longer than scheduled; negative means earlier than scheduled.
- **Reported Profit** uses the dataset's `benefit_per_order` field. It should not be interpreted as independently audited accounting profit.
- Geographic visuals use `customer_state` and `customer_city`; they describe customer locations, not necessarily delivery destinations.
- The dataset does not include enough carrier or warehouse detail to attribute the cause of delays.

## Data source and handling

See [`data/README.md`](data/README.md) for the source link, attribution, and handling notes. The raw CSV is not committed: it is large and contains customer-related fields that this report does not need to redistribute.
