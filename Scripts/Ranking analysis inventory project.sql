--- sales-
SELECT 
    ROUND(SUM(CASE WHEN COALESCE(s.salesdollars,0) < 0 THEN 0
            ELSE COALESCE(s.salesdollars,0)
        END),2) AS total_sales
FROM sales s;

---Average sales 
SELECT 
    ROUND(AVG(CASE WHEN COALESCE(s.salesdollars,0) < 0 THEN 0
            ELSE COALESCE(s.salesdollars,0)
        END),2) AS avg_sales
FROM sales s;


-----Sales by brand
SELECT Top 10
    e.brand,
    ROUND(SUM(CASE WHEN COALESCE(s.salesdollars,0) < 0 THEN 0
            ELSE COALESCE(s.salesdollars,0)
        END),2) AS total_sales
FROM sales s
JOIN end_inventory e
    ON s.inventoryid = e.inventoryid
GROUP BY e.brand
ORDER BY total_sales DESC;


----Sales by description
SELECT Top 10
    e.description,
    ROUND(SUM(CASE 
            WHEN COALESCE(s.salesdollars,0) < 0 THEN 0
            ELSE COALESCE(s.salesdollars,0)
        END),2) AS total_sales
FROM sales s
JOIN end_inventory e
    ON s.inventoryid = e.inventoryid
GROUP BY e.description
ORDER BY total_sales DESC;


------Sales by city
SELECT top 5
    e.city,
    ROUND(SUM(CASE WHEN COALESCE(s.salesdollars,0) < 0 THEN 0
            ELSE COALESCE(s.salesdollars,0)
        END),2) AS total_sales
FROM sales s
JOIN end_inventory e
    ON s.inventoryid = e.inventoryid
GROUP BY e.city
ORDER BY total_sales DESC;


----Low selling city
SELECT top 5
    e.city,
    ROUND(SUM(CASE WHEN COALESCE(s.salesdollars,0) < 0 THEN 0
            ELSE COALESCE(s.salesdollars,0)
        END),2) AS total_sales
FROM sales s
JOIN end_inventory e
    ON s.inventoryid = e.inventoryid
GROUP BY e.city
ORDER BY total_sales asc;


------Sales by store
SELECT top 10
    e.store,
    ROUND(SUM(CASE WHEN COALESCE(s.salesdollars,0) < 0 THEN 0
            ELSE COALESCE(s.salesdollars,0)
        END),2) AS total_sales
FROM sales s
JOIN end_inventory e
    ON s.inventoryid = e.inventoryid
GROUP BY e.store
ORDER BY total_sales DESC;


-----Sales by Month
SELECT top 3
    FORMAT(s.salesdate,'yyyy-MMM') AS sales_month,
    ROUND(SUM(CASE WHEN COALESCE(s.salesdollars,0) < 0 THEN 0
            ELSE COALESCE(s.salesdollars,0)
        END),2) AS total_sales
FROM sales s
GROUP BY FORMAT(s.salesdate,'yyyy-MMM')
ORDER BY sales_month;


-------------------------------------------------
----Profit explorations and measure
---Profit generating cities
SELECT top 10
    e.city,
    ROUND(SUM(CASE WHEN COALESCE(s.salesprice, 0) - COALESCE(pp.purchaseprice, 0) < 0 THEN 0
                ELSE COALESCE(s.salesprice, 0) - COALESCE(pp.purchaseprice, 0)
            END), 2 ) AS total_profit
FROM sales s
JOIN end_inventory e
    ON s.InventoryId = e.InventoryId
JOIN purchase_prices pp
    ON s.brand = pp.brand
   AND s.description = pp.description
   AND s.size = pp.size
GROUP BY e.city
ORDER BY total_profit DESC;


------Profit by description
SELECT top 10
    s.description,
    ROUND(SUM( CASE WHEN COALESCE(s.salesprice, 0) - COALESCE(pp.purchaseprice, 0) < 0 THEN 0
                ELSE COALESCE(s.salesprice, 0) - COALESCE(pp.purchaseprice, 0)
            END ),  2) AS total_profit
FROM sales s
JOIN purchase_prices pp
    ON s.brand = pp.brand
   AND s.description = pp.description
   AND s.size = pp.size
GROUP BY s.description
ORDER BY total_profit DESC;


----Most profitable brands
SELECT top 10
    s.brand,
    ROUND( SUM( CASE  WHEN COALESCE(s.salesprice, 0) - COALESCE(pp.purchaseprice, 0) < 0 THEN 0
                ELSE COALESCE(s.salesprice, 0) - COALESCE(pp.purchaseprice, 0)
                END ), 2) AS total_profit
FROM sales s
JOIN purchase_prices pp
    ON s.brand = pp.brand
   AND s.description = pp.description
   AND s.size = pp.size
GROUP BY s.brand
ORDER BY total_profit DESC;


-----Best bottom-line months
SELECT 
    FORMAT(s.salesdate, 'yyyy-MMM') AS profit_month,
    '$' + FORMAT(SUM( CASE WHEN COALESCE(s.salesdollars,0) - COALESCE(pp.purchaseprice,0) < 0 THEN 0
            ELSE COALESCE(s.salesdollars,0) - COALESCE(pp.purchaseprice,0)
        END), 'N2') AS total_profit
FROM sales s
JOIN purchase_prices pp
    ON s.brand = pp.brand
GROUP BY FORMAT(s.salesdate, 'yyyy-MMM')
ORDER BY profit_month;


----------------------------------
------Quantity exploration and magnitude
---Total Quantity
SELECT 
    SUM(CASE WHEN COALESCE(quantity, 0) < 0 THEN 0
            ELSE COALESCE(quantity, 0)
        END) AS total_quantity
FROM purchases;



----- Most efficient stores
SELECT top 10
    store,
    SUM( CASE WHEN COALESCE(Quantity, 0) <= 0 THEN 0
            ELSE COALESCE(Quantity, 0)
            END) AS total_quantity
FROM purchases 
GROUP BY store
ORDER BY total_quantity DESC;

------
----QUANTITY BY CITY
SELECT top 10
    e.city,
    SUM(CASE  WHEN COALESCE(p.Quantity, 0) <= 0 THEN 0
            ELSE COALESCE(p.Quantity, 0)
        END) AS total_quantity
FROM purchases p
JOIN end_inventory e
    ON p.InventoryId = e.InventoryId
GROUP BY e.city
ORDER BY total_quantity DESC;



----Most produced Brand
SELECT top 10
    Brand,
    SUM(
        CASE WHEN COALESCE(Quantity, 0) <= 0 THEN 0
            ELSE COALESCE(Quantity, 0)
        END) AS total_quantity
FROM purchases 
GROUP BY Brand
ORDER BY total_quantity DESC;


-------QUANTITY BY DESCRIPTION
SELECT top 10
    Description,
    SUM(CASE WHEN COALESCE(Quantity, 0) <= 0 THEN 0
            ELSE COALESCE(Quantity, 0)
        END) AS total_quantity
FROM purchases 
GROUP BY Description
ORDER BY total_quantity DESC;


-------Quantity by price class
SELECT top 2
    CASE WHEN p.PurchasePrice < 22 THEN 'Low'
        WHEN p.PurchasePrice BETWEEN 22 AND 50 THEN 'Average'
        WHEN p.PurchasePrice BETWEEN 51 AND 500 THEN 'High'
        ELSE 'Ultra-High'
    END AS price_class,
    SUM(CASE WHEN COALESCE(p.Quantity, 0) <= 0 THEN 0
            ELSE COALESCE(p.Quantity, 0)
        END) AS total_quantity
FROM purchases p
GROUP BY 
    CASE 
        WHEN p.PurchasePrice < 22 THEN 'Low'
        WHEN p.PurchasePrice BETWEEN 22 AND 50 THEN 'Average'
        WHEN p.PurchasePrice BETWEEN 51 AND 500 THEN 'High'
        ELSE 'Ultra-High'
    END
ORDER BY total_quantity DESC;


-----Quantity by Month
SELECT top 3
    FORMAT(PODate, 'yyyy-MMM') AS purchase_month,
    SUM(CASE WHEN COALESCE(quantity, 0) < 0 THEN 0
            ELSE COALESCE(quantity, 0)
        END ) AS total_quantity
FROM purchases
GROUP BY FORMAT(PODate, 'yyyy-MMM')
ORDER BY purchase_month;
