-------KPI cumulatives collected
SELECT
    month,
    -- Current month values
    '$' + FORMAT(total_sales, 'N2') AS current_sales,
    '$' + FORMAT(SUM(total_sales) OVER (PARTITION BY YEAR(month_start) 
            ORDER BY month_start ROWS UNBOUNDED PRECEDING ), 'N2') AS cumulative_sales,
    '$' + FORMAT(total_profit, 'N2') AS current_profit,
    '$' + FORMAT(SUM(total_profit) OVER (PARTITION BY YEAR(month_start) 
            ORDER BY month_start ROWS UNBOUNDED PRECEDING), 'N2') AS cumulative_profit,

total_sales_quantity AS current_quantity,
    SUM(total_sales_quantity) OVER (PARTITION BY YEAR(month_start) 
        ORDER BY month_start ROWS UNBOUNDED PRECEDING) AS cumulative_quantity
FROM (
    SELECT 
        -- Use first day of month to preserve chronological order
        DATEFROMPARTS(YEAR(s.salesdate), MONTH(s.salesdate), 1) AS month_start,
        FORMAT(s.salesdate, 'yyyy-MMM') AS month,
        -- Monthly totals
        SUM(CASE WHEN s.salesdollars < 0 OR s.salesdollars IS NULL THEN 0 ELSE s.salesdollars END) AS total_sales,
        SUM(CASE WHEN (s.salesprice - pp.purchaseprice) < 0 OR (s.salesprice - pp.purchaseprice) IS NULL THEN 0 ELSE (s.salesprice - pp.purchaseprice) END) AS total_profit,
        SUM(CASE WHEN s.salesquantity < 0 OR s.salesquantity IS NULL THEN 0 ELSE s.salesquantity END) AS total_sales_quantity

    FROM sales s
    JOIN purchase_prices pp
        ON s.brand = pp.brand
       AND s.description = pp.description
       AND s.size = pp.size
   WHERE s.salesdollars IS NOT NULL
      AND pp.purchaseprice IS NOT NULL
   GROUP BY YEAR(s.salesdate), MONTH(s.salesdate), FORMAT(s.salesdate, 'yyyy-MMM')
) t
ORDER BY month_start;


----------Cummulative profit
-----------------------------------------------------------------
SELECT
    month,
-- Current month profit
    '$' + FORMAT(total_profit, 'N2') AS current_profit,
 -- Cumulative profit within the year
    '$' + FORMAT(SUM(total_profit) OVER (PARTITION BY YEAR(month_start) 
            ORDER BY month_start ROWS UNBOUNDED PRECEDING), 'N2') AS cumulative_profit_year
FROM (
    SELECT 
        -- Use first day of month to preserve chronological order
        DATEFROMPARTS(YEAR(s.salesdate), MONTH(s.salesdate), 1) AS month_start,
        FORMAT(s.salesdate, 'yyyy-MMM') AS month,
        -- Monthly total profit
        SUM(CASE WHEN (s.salesprice - pp.purchaseprice) IS NULL 
                     OR (s.salesprice - pp.purchaseprice) < 0
                THEN 0
    ELSE (s.salesprice - pp.purchaseprice)
            END) AS total_profit
    FROM sales s
    JOIN purchase_prices pp
        ON s.brand = pp.brand
       AND s.description = pp.description
       AND s.size = pp.size
    WHERE s.salesprice IS NOT NULL
      AND pp.purchaseprice IS NOT NULL
    GROUP BY YEAR(s.salesdate), MONTH(s.salesdate), FORMAT(s.salesdate, 'yyyy-MMM')
) t
ORDER BY month_start;




----------Cummulative Sales
-----------------------------------------------------------------
SELECT
    month,
-- Current month sales
    '$' + FORMAT(total_sales, 'N2') AS current_sales,
-- Cumulative sales within the year
    '$' + FORMAT(SUM(total_sales) OVER (PARTITION BY YEAR(month_start) 
            ORDER BY month_start ROWS UNBOUNDED PRECEDING), 'N2') AS cumulative_sales_year
FROM (
    SELECT 
        -- First day of the month for proper chronological ordering
        DATEFROMPARTS(YEAR(s.salesdate), MONTH(s.salesdate), 1) AS month_start,
        FORMAT(s.salesdate, 'yyyy-MMM') AS month,
 -- Monthly total sales
        SUM(CASE WHEN s.salesdollars IS NULL OR s.salesdollars < 0 THEN 0
                ELSE s.salesdollars
            END) AS total_sales
        FROM sales s
        WHERE s.salesdollars IS NOT NULL
        GROUP BY YEAR(s.salesdate), MONTH(s.salesdate), FORMAT(s.salesdate, 'yyyy-MMM')
) t
ORDER BY month_start;



----------Cummulative Quantity
-----------------------------------------------------------------
SELECT
    month,
    -- Current month quantity
    total_sales_quantity AS current_quantity,
    -- Cumulative quantity within the year
    SUM(total_sales_quantity) OVER ( PARTITION BY YEAR(month_start)
        ORDER BY month_start
        ROWS UNBOUNDED PRECEDING) AS cumulative_quantity_year

FROM (
    SELECT
        -- First day of the month for proper chronological ordering
        DATEFROMPARTS(YEAR(s.salesdate), MONTH(s.salesdate), 1) AS month_start,
        FORMAT(s.salesdate, 'yyyy-MMM') AS month,
        -- Monthly total quantity
        SUM(CASE WHEN s.salesquantity IS NULL OR s.salesquantity < 0 THEN 0
                ELSE s.salesquantity
            END ) AS total_sales_quantity

    FROM sales s 
    WHERE s.salesquantity IS NOT NULL
    GROUP BY YEAR(s.salesdate), MONTH(s.salesdate), FORMAT(s.salesdate, 'yyyy-MMM')
) t

ORDER BY month_start;





------------------
---Cummulative quantity by store---
SELECT
    store,
    total_quantity AS current_store_quantity,

    -- Cumulative quantity from smallest store to largest store
    SUM(total_quantity) OVER (
    ORDER BY store
        ROWS UNBOUNDED PRECEDING) AS cumulative_quantity_by_store
FROM (
    SELECT
        s.store,
        SUM(CASE WHEN s.salesquantity IS NULL OR s.salesquantity < 0 THEN 0
                ELSE s.salesquantity
            END ) AS total_quantity
FROM sales s
    WHERE s.store IS NOT NULL
    GROUP BY s.store
) t
ORDER BY store;


