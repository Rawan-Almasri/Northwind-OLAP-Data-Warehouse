USE Northwind_ROLAP;
GO
select * from FactSales order by DateKey asc
--- 1. ETL DimDate

INSERT INTO Northwind_ROLAP.dbo.DimDate (
    DateKey,
    FullDate,
    DayNumber,
    MonthNumber,
    MonthName,
    QuarterNumber,
    YearNumber
)
SELECT DISTINCT --only Unique Values
    CONVERT(INT, FORMAT(OrderDate, 'yyyyMMdd')) AS DateKey, --- 1996-07-04 turn to 19960704 (key)
    CAST(OrderDate AS DATE) AS FullDate, --- 1996-07-04 14:30:00 to 1996-07-04
    MONTH(OrderDate) AS MonthNumber,
    DATENAME(MONTH, OrderDate) AS MonthName,
    DATEPART(QUARTER, OrderDate) AS QuarterNumber,
    YEAR(OrderDate) AS YearNumber
FROM Northwind.dbo.Orders
WHERE OrderDate IS NOT NULL;



--- 2. ETL DimCustomer
INSERT INTO Northwind_ROLAP.dbo.DimCustomer (
    CustomerID,
    CompanyName,
    ContactName,
    City,
    Region,
    Country
)
SELECT
    CustomerID,
    CompanyName,
    ContactName,
    City,
    Region,
    Country
FROM Northwind.dbo.Customers;


-- 3. ETL DimProduct from :: (Products + Categories + Suppliers)

INSERT INTO Northwind_ROLAP.dbo.DimProduct (
    ProductID,
    ProductName,
    CategoryName,
    SupplierName,
    QuantityPerUnit,
    Discontinued
)
SELECT
    P.ProductID,
    P.ProductName,
    C.CategoryName,
    S.CompanyName AS SupplierName,
    P.QuantityPerUnit,
    P.Discontinued
FROM Northwind.dbo.Products P
LEFT JOIN Northwind.dbo.Categories C  --note to use LEFT JOIN here
    ON P.CategoryID = C.CategoryID
LEFT JOIN Northwind.dbo.Suppliers S
    ON P.SupplierID = S.SupplierID;


-- 4. ETL DimEmployee

INSERT INTO Northwind_ROLAP.dbo.DimEmployee (
    EmployeeID,
    FullName,
    Title,
    City,
    Country,
    HireDate
)
SELECT
    EmployeeID,
    FirstName + ' ' + LastName AS FullName,
    Title,
    City,
    Country,
    CAST(HireDate AS DATE) AS HireDate
FROM Northwind.dbo.Employees;


-- 5. ETL FactSales from :: (Orders + Order Details)
INSERT INTO Northwind_ROLAP.dbo.FactSales (
    DateKey,
    CustomerKey,
    ProductKey,
    EmployeeKey,
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    Discount,
    Freight
)
SELECT
    CONVERT(INT, FORMAT(O.OrderDate, 'yyyyMMdd')) AS DateKey,

    C.CustomerKey,
    P.ProductKey,
    E.EmployeeKey,

    O.OrderID,
    OD.ProductID,

    OD.Quantity,
    OD.UnitPrice,
    OD.Discount,
    O.Freight
FROM Northwind.dbo.Orders O
INNER JOIN Northwind.dbo.[Order Details] OD
    ON O.OrderID = OD.OrderID

INNER JOIN Northwind_ROLAP.dbo.DimCustomer C
    ON O.CustomerID = C.CustomerID

INNER JOIN Northwind_ROLAP.dbo.DimProduct P
    ON OD.ProductID = P.ProductID

INNER JOIN Northwind_ROLAP.dbo.DimEmployee E
    ON O.EmployeeID = E.EmployeeID

INNER JOIN Northwind_ROLAP.dbo.DimDate D
    ON CONVERT(INT, FORMAT(O.OrderDate, 'yyyyMMdd')) = D.DateKey
WHERE O.OrderDate IS NOT NULL;
