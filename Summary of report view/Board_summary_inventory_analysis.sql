SELECT
    bi.InventoryId                                 AS InventoryId,

    bi.startDate                                  AS start_date,
    ei.endDate                                    AS end_date,

    vi.vendorNumber                               AS vendor_number,
    vi.vendorName                                 AS vendor_name,

    ei.store                                      AS store,
    ei.city                                       AS city,

    pp.description                                AS description,
    pp.brand                                      AS brand,

    -- Quantity (from inventory, handle nulls & negatives)
    SUM(CASE WHEN COALESCE(ei.onHand,0) < 0 THEN 0 
            ELSE COALESCE(ei.onHand,0)
        END
    ) AS quantity,
    -- Sales Quantity (handle nulls & negatives)
    SUM(CASE WHEN COALESCE(s.salesQuantity,0) < 0 THEN 0
            ELSE COALESCE(s.salesQuantity,0)
        END
    ) AS sales_quantity,
     -- Price (average price, 2dp, handle nulls & negatives)
    CAST(ROUND( AVG(CASE WHEN COALESCE(s.salesPrice,0) < 0 THEN 0
                    ELSE COALESCE(s.salesPrice,0)
                END
            ), 2
        ) AS DECIMAL(18,2)
    )AS price,
-- Profit (sum of profit, handle nulls, negatives & zeros)
    CAST(ROUND(SUM(CASE WHEN (COALESCE(s.salesPrice,0) - COALESCE(pp.purchasePrice,0)) <= 0
                        THEN 0
                    ELSE (COALESCE(s.salesPrice,0) - COALESCE(pp.purchasePrice,0))
                END
            ), 2
        ) AS DECIMAL(18,2)
    ) AS profit

FROM begin_inventory bi

JOIN end_inventory ei
    ON bi.InventoryId = ei.InventoryId

LEFT JOIN sales s
    ON ei.InventoryId = s.InventoryId

JOIN purchase_prices pp
    ON s.brand = pp.brand
   AND s.description = pp.description
   AND s.size = pp.size

JOIN vendor_invoice vi
    ON pp.vendorNumber = vi.vendorNumber

GROUP BY
    bi.InventoryId,
    bi.startDate,
    ei.endDate,
    vi.vendorNumber,
    vi.vendorName,
    ei.store,
    ei.city,
    pp.description,
    pp.brand

ORDER BY bi.InventoryId DESC;