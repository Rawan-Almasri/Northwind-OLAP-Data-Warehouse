USE Northwind_ROLAP
GO 

--------Create PARTITION FUNCTION --------
CREATE PARTITION FUNCTION pf_SalesDate (DATE)
AS RANGE RIGHT
FOR VALUES ('1997-01-01', '1998-01-01');
--This will not work because DateKey is INT

CREATE PARTITION FUNCTION pf_FactSales_DateKey (INT)
AS RANGE RIGHT
FOR VALUES (19970101,19980101);
GO

--------Create PARTITION SCHEMA--------
CREATE PARTITION SCHEME ps_FactSales_DateKey
AS PARTITION pf_FactSales_DateKey
ALL TO ([PRIMARY]);

--------Add FILEGROUP--------
ALTER DATABASE Northwind_ROLAP
ADD FILEGROUP FG1;

ALTER DATABASE Northwind_ROLAP
ADD FILEGROUP FG2;

ALTER DATABASE Northwind_ROLAP
ADD FILEGROUP FG3;

--------Add files--------
ALTER DATABASE Northwind_ROLAP
ADD FILE (NAME = N'FG1_Data', FILENAME = N'C:\DATABASES\northwindolap_FileGroup\FG1_Data.ndf', SIZE = 100MB)
TO FILEGROUP FG1;
GO

ALTER DATABASE Northwind_ROLAP
ADD FILE (NAME = N'FG2_Data', FILENAME = N'C:\DATABASES\northwindolap_FileGroup\FG2_Data.ndf', SIZE = 100MB)
TO FILEGROUP FG1;
GO

ALTER DATABASE Northwind_ROLAP
ADD FILE (NAME = N'FG3_Data', FILENAME = N'C:\DATABASES\northwindolap_FileGroup\FG3_Data.ndf', SIZE = 100MB)
TO FILEGROUP FG1;
GO

CREATE PARTITION SCHEME ps_FactSales_DateKey2
AS PARTITION pf_FactSales_DateKey
TO (FG1, FG2, FG3);

-------- CREATE CLUSTERD INDEX --------
CREATE CLUSTERED INDEX CIX_FactSales_DateKey
ON FactSales(DateKey)
ON ps_FactSales_DateKey(DateKey);


SELECT name, type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID('FactSales');


ALTER TABLE FactSales
DROP CONSTRAINT CIX_FactSales_DateKey; 


CREATE CLUSTERED INDEX CIX_FactSales_DateKey
ON FactSales(DateKey)
ON ps_FactSales_DateKey(DateKey);


ALTER TABLE FactSales
ADD CONSTRAINT PK_FactSales
PRIMARY KEY NONCLUSTERED (SalesKey, DateKey);
GO

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
    $PARTITION.pf_FactSales_DateKey(DateKey) AS PartitionNumber
FROM FactSales
ORDER BY DateKey;


-------- DELETE--------

--DELETE INDEX
DROP INDEX CIX_FactSales_DateKey
ON FactSales;
GO

--DELETE PK
ALTER TABLE FactSales
DROP CONSTRAINT PK_FactSales;
GO

CREATE CLUSTERED INDEX CIX_FactSales
ON FactSales(SalesKey)
ON [PRIMARY];
GO

-- DROP PS
DROP PARTITION SCHEME ps_FactSales_DateKey;
GO



DROP PARTITION FUNCTION pf_FactSales_DateKey;
GO


SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc,
    ds.name AS DataSpaceName
FROM sys.indexes i
JOIN sys.tables t 
    ON i.object_id = t.object_id
JOIN sys.data_spaces ds
    ON i.data_space_id = ds.data_space_id
WHERE ds.name = 'ps_FactSales_DateKey';

--DELETE FILES 
ALTER DATABASE Northwind_ROLAP REMOVE FILE FG1_Data;
ALTER DATABASE Northwind_ROLAP REMOVE FILE FG2_Data;
ALTER DATABASE Northwind_ROLAP REMOVE FILE FG3_Data;

--DELETE FILE GROUP 
ALTER DATABASE Northwind_ROLAP REMOVE FILEGROUP FG1;
ALTER DATABASE Northwind_ROLAP REMOVE FILEGROUP FG2;
ALTER DATABASE Northwind_ROLAP REMOVE FILEGROUP FG3;



