USE Northwind_ROLAP
GO

--ROLLUP
SELECT
p.CategoryName,
    D.YearNumber,
    D.MonthNumber,
    SUM(F.NetSales) AS TotalSales
FROM FactSales F
JOIN DimDate D ON F.DateKey = D.DateKey
JOIN DimProduct p ON p.ProductKey = f.ProductID
GROUP BY
p.CategoryName,
ROLLUP
(
    D.YearNumber,
    D.MonthNumber
)
ORDER BY
    D.YearNumber,
    D.MonthNumber;



--Partial ROLLUP
SELECT
    P.CategoryName,
    D.YearNumber,
    D.MonthNumber,
    SUM(F.NetSales) AS TotalSales
FROM FactSales F
JOIN DimDate D ON F.DateKey = D.DateKey
JOIN DimProduct P ON F.ProductKey = P.ProductKey
GROUP BY
    P.CategoryName,
    ROLLUP
    (D.YearNumber, D.MonthNumber)
ORDER BY
    P.CategoryName,
    D.YearNumber,
    D.MonthNumber;


-- DRILL DOWN 
SELECT
    D.YearNumber,
    SUM(F.NetSales) AS TotalSales
FROM FactSales F JOIN DimDate D ON F.DateKey = D.DateKey
GROUP BY
    D.YearNumber
	
ORDER BY
    D.YearNumber;

	6

	-- drill down for days in one month
SELECT
    D.YearNumber,
    D.MonthNumber,
    D.DayNumber,
    SUM(F.NetSales) AS TotalSales
FROM FactSales F JOIN DimDate D ON F.DateKey = D.DateKey
WHERE D.YearNumber = 1997 AND D.MonthNumber = 7
GROUP BY
    D.YearNumber,
    D.MonthNumber,
    D.DayNumber
ORDER BY
    D.DayNumber;


-- slice 
SELECT
    D.YearNumber,
    P.CategoryName,
    SUM(F.NetSales) AS TotalSales
FROM FactSales F
JOIN DimDate D ON F.DateKey = D.DateKey
JOIN DimProduct P ON F.ProductKey = P.ProductKey
WHERE D.YearNumber = 1997
GROUP BY
    D.YearNumber,
    P.CategoryName
ORDER BY TotalSales DESC;


-- dice 
SELECT
    D.YearNumber,
    C.Country,
    P.CategoryName,
    SUM(F.NetSales) AS TotalSales
FROM FactSales F
JOIN DimDate D ON F.DateKey = D.DateKey
JOIN DimCustomer C ON F.CustomerKey = C.CustomerKey
JOIN DimProduct P ON F.ProductKey = P.ProductKey
WHERE D.YearNumber IN (1997, 1996) 
  AND C.Country IN ('USA', 'Germany')
  AND P.CategoryName IN ('Beverages', 'Seafood')
GROUP BY
    D.YearNumber,
    C.Country,
    P.CategoryName
ORDER BY TotalSales DESC;



-- cube 
SELECT
    D.YearNumber,
    p.CategoryName,
    SUM(F.NetSales) AS TotalSales
FROM FactSales F
JOIN DimDate D ON F.DateKey = D.DateKey
JOIN DimProduct p   ON p.ProductKey = f.ProductKey
GROUP BY CUBE
(
    D.YearNumber,
    p.CategoryName
)
ORDER BY
    D.YearNumber,
    p.CategoryName;





