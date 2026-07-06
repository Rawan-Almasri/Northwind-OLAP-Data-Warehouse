USE Northwind_ROLAP
GO 

ALTER TABLE FactSales
ADD HashKey AS (CustomerKey % 4) ; 


CREATE PARTITION FUNCTION pf_Date (INT)
AS RANGE RIGHT
FOR VALUES (19970101, 19980101);


CREATE PARTITION SCHEME ps_Date
AS PARTITION pf_Date
ALL TO ([PRIMARY]);

CREATE CLUSTERED INDEX CIX_FactSales
ON FactSales(DateKey, HashKey) --ADD HashKey Here
ON ps_Date(DateKey);

--You will get error so delete the index first
SELECT name, type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID('FactSales');

DROP INDEX CIX_FactSales_DateKey ON FactSales;
GO

--Now create agin
CREATE CLUSTERED INDEX CIX_FactSales
ON FactSales(DateKey, HashKey) --ADD HashKey Here
ON ps_Date(DateKey);




-------- Check partitions--------
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    p.partition_number,
    p.rows
FROM sys.partitions p
JOIN sys.tables t 
    ON p.object_id = t.object_id
JOIN sys.indexes i
    ON p.object_id = i.object_id
   AND p.index_id = i.index_id
WHERE t.name = 'FactSales'
ORDER BY p.partition_number;

-------- Check date in partition--------
SELECT 
    DateKey,
    HashKey,
    $PARTITION.pf_Date(DateKey) AS PartitionNumber
FROM FactSales
ORDER BY DateKey, HashKey;
