------Explorating for duplicates
----Inventory_beginning
SELECT
count(distinct(InventoryId)) no_of_id_start
FROM begin_inventory;

SELECT
count(InventoryId) no_of_id_start
FROM begin_inventory;

SELECT count(distinct(store)) No_of_stores
FROM begin_inventory;

SELECT count(store) No_of_stores
FROM begin_inventory;

---End inventory

SELECT
count(distinct(InventoryId)) no_of_id_end
FROM end_inventory;

SELECT
count(InventoryId) no_of_id_end
FROM end_inventory;

SELECT count(distinct(store)) No_of_dist_stores
FROM end_inventory;

SELECT count(store) No_of_stores
FROM end_inventory;

----General Table and dimensions exploration 

SELECT
count(distinct(City)) no_of_id_start
FROM begin_inventory;

SELECT
count(distinct(City)) no_of_id_start
FROM end_inventory;

---fix city name proper
SELECT DISTINCT
    UPPER(LEFT(City, 1)) + LOWER(SUBSTRING(City, 2, LEN(City))) AS City_names
FROM begin_inventory;



SELECT
InventoryId as sales
FROM sales


SELECT
count(distinct(InventoryId)) as No_of_dist_sales
FROM sales


SELECT
count(InventoryId) as No_of_sales
FROM sales


select
count(InventoryId) / count(distinct(InventoryId)) 
from sales


SELECT
COUNT(*) AS row_count
FROM vendor_invoice;



SELECT
COUNT(distinct(vendornumber)) AS row_count
FROM vendor_invoice;



SELECT
COUNT(vendornumber)  / COUNT(distinct(vendornumber)) as avg_vendor_receipt_count
FROM vendor_invoice;

-----Receipt by vendors
SELECT 
    VendorName,
    VendorNumber,
    count(1) no_of_receipt
FROM vendor_invoice
GROUP BY VendorName,
         VendorNumber


SELECT *
FROM purchases;



SELECT 
InventoryId
FROM purchases;


SELECT 
count(InventoryId) N0_of_inventory
FROM purchases;



SELECT 
count(distinct(InventoryId)) N0_of_dist_inventory
FROM purchases;


select 
count(InventoryId) / count(distinct(InventoryId)) avg_inv_per_purchase
FROM purchases;


SELECT *
FROM purchase_prices;


SELECT 
count(Brand) No_of_brand
FROM purchase_prices;


SELECT 
count(distinct(Brand)) dist_brands
FROM purchase_prices;


SELECT 
DISTINCT Classification
FROM sales;

SELECT 
count(DISTINCT Store)
FROM sales


SELECT
DISTINCT Store
FROM sales
ORDER BY Store;


SELECT
DISTINCT Brand
FROM begin_inventory
ORDER BY Brand;

SELECT
count( Brand) brand_count
FROM begin_inventory

SELECT
count(DISTINCT Brand) brand_count
FROM begin_inventory



SELECT
count(DISTINCT Brand) brand_count
FROM sales


SELECT
count(Brand) brand_count
FROM sales


select 
count(distinct(size)) dist_size_count
from begin_inventory


select 
distinct size dist_size
from begin_inventory


select 
count(brand) brands
from end_inventory

select 
count(distinct brand) final_no_of_brands
from end_inventory


-----Start and end brands
SELECT 
    COUNT(DISTINCT b.Brand) AS begin_brands,
    COUNT(DISTINCT e.Brand) AS end_brands
FROM begin_inventory b
FULL OUTER JOIN end_inventory e
    ON b.Brand = e.Brand;


---Brands created between start and end
SELECT COUNT(DISTINCT e.Brand) AS brands_created_between
FROM end_inventory e
WHERE NOT EXISTS (
    SELECT 1
    FROM begin_inventory b
    WHERE b.Brand = e.Brand
);

----Number of brands lost 
SELECT COUNT(DISTINCT b.Brand) AS lost_brands
FROM begin_inventory b
WHERE NOT EXISTS (
    SELECT 1
    FROM end_inventory e
    WHERE e.Brand = b.Brand
);


----All about brands collected
SELECT 
    (SELECT COUNT(DISTINCT Brand) FROM begin_inventory) AS begin_brands,
    (SELECT COUNT(DISTINCT Brand) FROM end_inventory)   AS end_brands,

    (SELECT COUNT(DISTINCT e.Brand)
     FROM end_inventory e
     WHERE NOT EXISTS (
         SELECT 1 FROM begin_inventory b
         WHERE b.Brand = e.Brand
     )) AS new_brands,

    (SELECT COUNT(DISTINCT b.Brand)
     FROM begin_inventory b
     WHERE NOT EXISTS (
         SELECT 1 FROM end_inventory e
         WHERE e.Brand = b.Brand
     )) AS lost_brands,

    (SELECT COUNT(DISTINCT Brand) FROM end_inventory)
    -
    (SELECT COUNT(DISTINCT Brand) FROM begin_inventory) AS net_change;




select 
count(distinct(description)) all_desc
from begin_inventory



select 
distinct description
from begin_inventory



        SELECT 
            description,
            COUNT(DISTINCT brand) AS brand_count
        FROM begin_inventory
        GROUP BY description
        HAVING COUNT(DISTINCT brand) > 1;

----
       
       SELECT description
FROM begin_inventory
GROUP BY description
HAVING COUNT(DISTINCT brand) > 1;


---
SELECT
    SUM(CASE WHEN brand_count = 1 THEN 1 ELSE 0 END) AS clean_descriptions,
    SUM(CASE WHEN brand_count > 1 THEN 1 ELSE 0 END) AS dirty_descriptions,
    SUM(CASE WHEN brand_count = 1 THEN 1 ELSE 0 END)
    -
    SUM(CASE WHEN brand_count > 1 THEN 1 ELSE 0 END) AS difference
FROM (
    SELECT description, COUNT(DISTINCT brand) AS brand_count
    FROM begin_inventory
    GROUP BY description
) x;





SELECT 
    brand,
    COUNT(DISTINCT description) AS product_count
FROM begin_inventory
GROUP BY brand
ORDER BY product_count DESC;


-----Price exploration

SELECT 
    FORMAT(price, 'N2') AS price_2dp
FROM begin_inventory;


SELECT DISTINCT
    CAST(price AS DECIMAL(10,2)) AS prices
FROM begin_inventory;


select
avg (price)
from begin_inventory 


----Price segmentation
SELECT 
    CASE 
        WHEN price < 22 THEN 'Low'
        WHEN price BETWEEN 22 AND 50 THEN 'Average'
        WHEN price BETWEEN 51 AND 500 THEN 'High'
        ELSE 'Ultra-High'
    END AS price_category,
    COUNT(DISTINCT brand) AS brand_count
FROM begin_inventory
GROUP BY 
    CASE 
        WHEN price < 22 THEN 'Low'
        WHEN price BETWEEN 22 AND 50 THEN 'Average'
        WHEN price BETWEEN 51 AND 500 THEN 'High'
        ELSE 'Ultra-High'
    END
ORDER BY brand_count DESC;



SELECT 
    price_category,
    COUNT(brand) AS brand_count,
    STUFF((
        SELECT ', ' + t2.brand
        FROM (
            SELECT DISTINCT
                brand,
                CASE 
                    WHEN price < 22 THEN 'Low'
                    WHEN price BETWEEN 22 AND 50 THEN 'Average'
                    WHEN price BETWEEN 51 AND 500 THEN 'High'
                    ELSE 'Ultra-High'
                END AS price_category
            FROM begin_inventory
        ) t2
        WHERE t2.price_category = t1.price_category
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS brands_in_category
FROM (
    SELECT DISTINCT
        CASE 
            WHEN price < 22 THEN 'Low'
            WHEN price BETWEEN 22 AND 50 THEN 'Average'
            WHEN price BETWEEN 51 AND 500 THEN 'High'
            ELSE 'Ultra-High'
        END AS price_category,
        brand
    FROM begin_inventory
) t1
GROUP BY price_category;



-------
SELECT 
    description,
    AVG(CAST(price AS DECIMAL(10,2))) AS avg_price
FROM begin_inventory
GROUP BY description;



--------

----Average price of descriptions
SELECT 
    SUM(avg_price) / COUNT(description) AS overall_avg_price
FROM (
    SELECT 
        description,
        AVG(CAST(price AS DECIMAL(10,2))) AS avg_price
    FROM begin_inventory
    GROUP BY description
) t;


----Price category of each descriptions
SELECT 
    description,
    avg_price,
    CASE 
        WHEN avg_price < 41 THEN 'Low'
        WHEN avg_price BETWEEN 41 AND 100 THEN 'Medium'
        WHEN avg_price BETWEEN 101 AND 200 THEN 'High'
        ELSE 'Ultra-High'
    END AS price_category
FROM (
    SELECT 
        description,
        AVG(CAST(price AS DECIMAL(10,2))) AS avg_price
    FROM begin_inventory
    GROUP BY description
) t;


---------
--Descripions in each price category
SELECT 
    price_category,
    COUNT(description) AS description_count,
    STRING_AGG(CAST(description AS NVARCHAR(MAX)), ', ') AS descriptions_in_category
FROM (
    SELECT 
        description,
        AVG(CAST(price AS DECIMAL(10,2))) AS avg_price,
        CASE 
            WHEN AVG(CAST(price AS DECIMAL(10,2))) < 41 THEN 'Low'
            WHEN AVG(CAST(price AS DECIMAL(10,2))) BETWEEN 41 AND 100 THEN 'Medium'
            WHEN AVG(CAST(price AS DECIMAL(10,2))) BETWEEN 101 AND 200 THEN 'High'
            ELSE 'Ultra-High'
        END AS price_category
    FROM begin_inventory
    GROUP BY description
) t
GROUP BY price_category
ORDER BY description_count DESC;
--------------------


---Descriptions and their price_category and their average price
SELECT 
    price_category,
    description,
    avg_price
FROM (
    SELECT 
        description,
        AVG(CAST(price AS DECIMAL(10,2))) AS avg_price,
        CASE 
            WHEN AVG(CAST(price AS DECIMAL(10,2))) < 41 THEN 'Low'
            WHEN AVG(CAST(price AS DECIMAL(10,2))) BETWEEN 41 AND 100 THEN 'Medium'
            WHEN AVG(CAST(price AS DECIMAL(10,2))) BETWEEN 101 AND 200 THEN 'High'
            ELSE 'Ultra-High'
        END AS price_category
    FROM begin_inventory
    GROUP BY description
) t
ORDER BY price_category, avg_price;


-------------------------------------------------------------------------------------
----Purchase details
select 
ponumber
from purchases


select 
count(distinct(ponumber))
from purchases


----Date details
----Purchase details
select 
PODate
from purchases


select 
count(distinct(PODate))
from purchases


-----Purchases date
SELECT 
    FORMAT(PODate, 'yyyy-MMM') AS purchase_month,
    COUNT(DISTINCT PODate) AS distinct_purchase_days
FROM purchases
GROUP BY FORMAT(PODate, 'yyyy-MMM')
ORDER BY purchase_month;


-----Receiving date
select 
receivingdate
from purchases


select 
count(distinct(receivingdate)) receive_date_distinct
from purchases


SELECT 
    FORMAT(DATETRUNC(month, receivingdate), 'yyyy-MMM') AS receive_month,
    COUNT(DISTINCT receivingdate) AS distinct_receive_date
FROM purchases
GROUP BY DATETRUNC(month, receivingdate)
ORDER BY DATETRUNC(month, receivingdate);




---------Invoice date
select 
InvoiceDate
from purchases


select 
count(distinct(InvoiceDate)) invoice_date_distinct
from purchases


SELECT 
    FORMAT(DATETRUNC(month, InvoiceDate), 'yyyy-MMM') AS invoice_month,
    COUNT(DISTINCT InvoiceDate) AS distinct_invoice_date
FROM purchases
GROUP BY DATETRUNC(month, InvoiceDate)
ORDER BY DATETRUNC(month, InvoiceDate);



---------Pay Date
select 
PayDate
from purchases


select 
count(distinct(PayDate)) pay_date_distinct
from purchases


SELECT 
    FORMAT(DATETRUNC(month, PayDate), 'yyyy-MMM') AS pay_month,
    COUNT(DISTINCT PayDate) AS distinct_pay_date
FROM purchases
GROUP BY DATETRUNC(month, PayDate)
ORDER BY DATETRUNC(month, PayDate);


