--ROW_NUMBER()

SELECT
    ROW_NUMBER() OVER (
        ORDER BY SUM(F.NetSales) DESC
    ) AS RowNum,
    P.ProductName,
    SUM(F.NetSales) AS TotalSales
FROM FactSales F JOIN DimProduct P  ON F.ProductKey = P.ProductKey
GROUP BY P.ProductName;

--RANK()

SELECT
    RANK() OVER (
        ORDER BY SUM(F.NetSales) DESC
    ) AS SalesRank,
    P.ProductName,
    SUM(F.NetSales) AS TotalSales

FROM FactSales F JOIN DimProduct P ON F.ProductKey = P.ProductKey
GROUP BY P.ProductName;
 
--DENSE_RANK()
SELECT
    DENSE_RANK() OVER (
        ORDER BY SUM(F.NetSales) DESC
    ) AS DenseRank,
    P.ProductName,
    SUM(F.NetSales) AS TotalSales

FROM FactSales F JOIN DimProduct P ON F.ProductKey = P.ProductKey
GROUP BY P.ProductName;

--NTILE()
SELECT
    C.CompanyName,
    SUM(F.NetSales) AS TotalSales,
    NTILE(4) OVER (
        ORDER BY SUM(F.NetSales) DESC
    ) AS SalesGroup
FROM FactSales F JOIN DimCustomer C ON F.CustomerKey = C.CustomerKey
GROUP BY C.CompanyName;


