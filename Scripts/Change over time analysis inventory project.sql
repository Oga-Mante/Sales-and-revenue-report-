-----------
-----Sales month on month
SELECT 
    month,
    total_sales,
    total_sales_quantity,
    distinct_inventory_count,
    distinct_store_count,
    LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales,
    ROUND( CASE WHEN LAG(total_sales) OVER (ORDER BY month) = 0 
              OR LAG(total_sales) OVER (ORDER BY month) IS NULL THEN NULL
            ELSE 
            ((total_sales - LAG(total_sales) OVER (ORDER BY month)) 
                 / LAG(total_sales) OVER (ORDER BY month)) * 100
        END, 2 ) AS MoM_change_percent
FROM (
    SELECT 
        FORMAT(s.salesdate, 'yyyy-MMM') AS month,
        SUM(CASE  WHEN s.salesdollars < 0 OR s.salesdollars IS NULL THEN 0
                ELSE s.salesdollars
            END) AS total_sales,
        SUM(CASE WHEN s.salesquantity < 0 OR s.salesquantity IS NULL THEN 0
                ELSE s.salesquantity
            END) AS total_sales_quantity,
        COUNT(DISTINCT ei.InventoryId) AS distinct_inventory_count,
        COUNT(DISTINCT s.store) AS distinct_store_count
     FROM sales s
    JOIN end_inventory ei
        ON s.InventoryId = ei.InventoryId
    WHERE s.salesdollars IS NOT NULL
      AND s.salesdollars >= 0
    GROUP BY FORMAT(s.salesdate, 'yyyy-MMM')
) t
ORDER BY total_sales_quantity DESC;
---------------------

---------------------------------------------------------------
------Month on Month profit------
SELECT 
    month,
    '$' + FORMAT(total_profit, 'N2') AS total_profit,
    total_sales_quantity,
    distinct_inventory_count,
    distinct_store_count,
    '$' + FORMAT(prev_month_profit, 'N2') AS prev_month_profit,
    CAST(ROUND(CASE WHEN prev_month_profit = 0 
                  OR prev_month_profit IS NULL
                THEN NULL
                ELSE ((total_profit - prev_month_profit) / prev_month_profit) * 100
            END, 2 ) AS VARCHAR(20)) + '%' AS MoM_profit_change_percent

FROM (
    SELECT 
        FORMAT(s.salesdate, 'yyyy-MMM') AS month,
        SUM(CASE WHEN (s.salesprice - pp.purchaseprice) < 0 
                     OR (s.salesprice - pp.purchaseprice) IS NULL
                THEN 0
                ELSE (s.salesprice - pp.purchaseprice)
            END ) AS total_profit,
        SUM(CASE 
                WHEN s.salesquantity < 0 OR s.salesquantity IS NULL 
                THEN 0
                ELSE s.salesquantity
            END
        ) AS total_sales_quantity,
        COUNT(DISTINCT ei.InventoryId) AS distinct_inventory_count,
        COUNT(DISTINCT s.store) AS distinct_store_count,
        LAG(SUM(CASE WHEN (s.salesprice - pp.purchaseprice) < 0 
                         OR (s.salesprice - pp.purchaseprice) IS NULL
                THEN 0
                    ELSE (s.salesprice - pp.purchaseprice)
                END)) OVER (ORDER BY FORMAT(s.salesdate, 'yyyy-MMM')) AS prev_month_profit
     FROM sales s
    JOIN purchase_prices pp
        ON s.brand = pp.brand
       AND s.description = pp.description
       AND s.size = pp.size

    JOIN end_inventory ei
        ON s.InventoryId = ei.InventoryId

    WHERE s.salesprice IS NOT NULL
      AND pp.purchaseprice IS NOT NULL

    GROUP BY FORMAT(s.salesdate, 'yyyy-MMM')
) t
ORDER BY total_profit DESC;



--------------------------
---------Quantity Month on Month
SELECT 
    month,
    total_sales_quantity,
    distinct_brand_count,
    distinct_inventory_count,
    distinct_store_count,
    LAG(total_sales_quantity) OVER (ORDER BY month) AS prev_month_quantity,
    ROUND(CASE WHEN LAG(total_sales_quantity) OVER (ORDER BY month) = 0
              OR LAG(total_sales_quantity) OVER (ORDER BY month) IS NULL
            THEN NULL
            ELSE ((total_sales_quantity - LAG(total_sales_quantity) OVER (ORDER BY month))
                 / LAG(total_sales_quantity) OVER (ORDER BY month)) * 100
        END, 2
    ) AS MoM_quantity_change_percent
FROM (
    SELECT FORMAT(s.salesdate, 'yyyy-MMM') AS month,
           SUM(CASE WHEN s.salesquantity < 0 OR s.salesquantity IS NULL
                THEN 0
                ELSE s.salesquantity
            END) AS total_sales_quantity,
           COUNT(DISTINCT s.brand) AS distinct_brand_count,
           COUNT(DISTINCT s.InventoryId) AS distinct_inventory_count,
           COUNT(DISTINCT s.store) AS distinct_store_count
    FROM sales s
    WHERE s.salesquantity IS NOT NULL
      AND s.salesquantity >= 0
    GROUP BY FORMAT(s.salesdate, 'yyyy-MMM')
) t
    ORDER BY month;






