-- Five customer cities with the lowest total dataset-reported profit.
-- A low-ranked city is not necessarily loss-making; inspect the returned values.
USE supply_chain_db;

SELECT
    c.customer_city,
    ROUND(SUM(f.benefit_per_order), 2) AS reported_profit_usd
FROM fact_orders AS f
JOIN dim_customers AS c ON f.customer_id = c.customer_id
GROUP BY c.customer_city
ORDER BY reported_profit_usd ASC
LIMIT 5;
