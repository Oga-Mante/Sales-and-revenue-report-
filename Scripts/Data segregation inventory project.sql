---City profit segregation by class
---------------------
SELECT
    city,
    CAST(total_profit AS DECIMAL(18,2)) AS total_profit,
    CAST(avg_city_profit AS DECIMAL(18,2)) AS average_profit_by_city,
    CAST(total_profit - avg_city_profit AS DECIMAL(18,2)) 
            AS deviation_from_average,
    CAST(profit_percentile * 100 AS DECIMAL(5,2)) AS profit_percentile,

    CASE WHEN profit_percentile <= 0.15 THEN 'High-income-city'
        WHEN profit_percentile > 0.15 AND profit_percentile <= 0.75 THEN 'Medium-income-city'
        ELSE 'Low-income-city'
    END AS city_class
FROM (
    SELECT
        city,
        total_profit,
-- Average profit across all cities (after cleaning)
        AVG(total_profit) OVER () AS avg_city_profit,
-- Percentile rank of each city by profit
        PERCENT_RANK() OVER (ORDER BY total_profit DESC) AS profit_percentile

    FROM (
        SELECT
            ei.city AS city,
-- Total profit per city (cleaned: nulls, negatives, zeros)
            SUM(CASE WHEN COALESCE(s.salesprice,0) - COALESCE(pp.purchaseprice,0) <= 0
                    THEN 0
                    ELSE COALESCE(s.salesprice,0) - COALESCE(pp.purchaseprice,0)
                END) * 1.0 AS total_profit
FROM sales s
        JOIN purchase_prices pp
            ON s.brand = pp.brand
           AND s.description = pp.description
           AND s.size = pp.size
        JOIN end_inventory ei
            ON s.InventoryId = ei.InventoryId
         GROUP BY ei.city
        ) city_profit
        ) ranked_cities
ORDER BY total_profit DESC;



--------------------------------------------------
------Quantity segregation by description
SELECT
    description,
    CAST(total_quantity AS DECIMAL(18,2)) AS total_quantity,
    CAST(avg_description_quantity AS DECIMAL(18,2)) AS average_quantity_by_description,
      CASE WHEN avg_description_quantity = 0 THEN NULL
        ELSE CAST(ROUND( ((total_quantity - avg_description_quantity) / avg_description_quantity) * 100,
            2)AS DECIMAL(18,2))
    END AS percent_deviation_from_average,
    CAST(quantity_percentile * 100 AS DECIMAL(5,2)) AS quantity_percentile,
    CASE WHEN quantity_percentile <= 0.15 THEN 'High-quantity-description'
        WHEN quantity_percentile > 0.15 AND quantity_percentile <= 0.75 THEN 'Medium-quantity-description'
        ELSE 'Low-quantity-description'
    END AS description_class
FROM (
    SELECT
        description,
        total_quantity,
     -- Average quantity across all descriptions (after cleaning)
        AVG(total_quantity) OVER () AS avg_description_quantity,
     -- Percentile rank of each description by quantity
        PERCENT_RANK() OVER (ORDER BY total_quantity DESC) AS quantity_percentile
     FROM (
        SELECT
            p.description AS description,
        -- Total quantity per description (handle nulls, negatives, zeros)
            SUM(CASE WHEN COALESCE(p.quantity,0) <= 0 THEN 0
                    ELSE COALESCE(p.quantity,0)
                END ) * 1.0 AS total_quantity
        FROM purchases p
        GROUP BY p.description
    ) description_quantity
) ranked_descriptions
ORDER BY total_quantity DESC;



-------------------------------------------------------------------
------Sales quantity segregation by profit(good to know premium products)
SELECT
    description,
    CAST(total_sales_quantity AS DECIMAL(18,2)) AS total_sales_quantity,
    CAST(total_profit AS DECIMAL(18,2)) AS total_profit,
    CAST(avg_profit AS DECIMAL(18,2)) AS average_profit_by_description,
    CASE WHEN total_profit > avg_profit THEN 'High-profit'
        WHEN total_profit < avg_profit THEN 'Low-profit'
        ELSE 'Average'
    END AS profit_class
FROM (
    SELECT
        description,
        total_sales_quantity,
        total_profit,
    AVG(total_profit) OVER () AS avg_profit
    FROM (
        SELECT
            s.description AS description,
        -- Total sales quantity per description (cleaned)
            SUM( CASE WHEN COALESCE(s.salesquantity,0) <= 0 THEN 0
                    ELSE COALESCE(s.salesquantity,0)
                END
            ) * 1.0 AS total_sales_quantity,
        -- Total profit per description (cleaned)
            SUM(CASE WHEN COALESCE(s.salesprice,0) - COALESCE(pp.purchaseprice,0) <= 0
                    THEN 0
                    ELSE COALESCE(s.salesprice,0) - COALESCE(pp.purchaseprice,0)
                END
            ) * 1.0 AS total_profit
        FROM sales s
        JOIN purchase_prices pp
            ON s.brand = pp.brand
           AND s.description = pp.description
           AND s.size = pp.size
            GROUP BY s.description
    ) description_profit_quantity
) classified_descriptions
ORDER BY total_profit DESC;
