-- Revenue and dataset-reported profit margin by product category.
USE supply_chain_db;

SELECT
    p.category_name,
    ROUND(SUM(f.sales_amount), 2) AS total_sales_usd,
    ROUND(SUM(f.benefit_per_order), 2) AS reported_profit_usd,
    ROUND(100.0 * SUM(f.benefit_per_order) / NULLIF(SUM(f.sales_amount), 0), 2) AS reported_profit_margin_pct
FROM fact_orders AS f
JOIN dim_products AS p ON f.product_id = p.product_id
GROUP BY p.category_name
ORDER BY reported_profit_margin_pct DESC;
