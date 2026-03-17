SELECT 'Total Quantity' AS measure_name,
       CAST(SUM(salesquantity) AS VARCHAR(50)) AS measure_value
FROM sales

UNION ALL

SELECT 'Average Quantity' AS measure_name,
       CAST(ROUND(AVG(salesquantity), 2) AS VARCHAR(50)) AS measure_value
FROM sales

UNION ALL

SELECT 'Average Price' AS measure_name,
       '$' + FORMAT(AVG(salesprice), 'N2') AS measure_value
FROM sales

UNION ALL

SELECT 'Total Profit' AS measure_name,
       '$' + FORMAT(SUM(s.salesprice - pp.purchaseprice), 'N2') AS measure_value
FROM sales s
JOIN purchase_prices pp
    ON s.brand = pp.brand
   AND s.description = pp.description
   AND s.size = pp.size

UNION ALL

SELECT 'Total Sales' AS measure_name,
       '$' + FORMAT(SUM(salesdollars), 'N2') AS measure_value
FROM sales

UNION ALL

SELECT 'Average Sales' AS measure_name,
       '$' + FORMAT(AVG(salesdollars), 'N2') AS measure_value
FROM sales

UNION ALL

SELECT 'Distinct Cities' AS measure_name,
       CAST(COUNT(DISTINCT city) AS VARCHAR(50)) AS measure_value
FROM begin_inventory

UNION ALL

SELECT 'Distinct Stores' AS measure_name,
       CAST(COUNT(DISTINCT store) AS VARCHAR(50)) AS measure_value
FROM begin_inventory;
