CREATE DATABASE Northwind_ROLAP;
GO

USE Northwind_ROLAP;
GO

CREATE TABLE DimDate (
    DateKey INT NOT NULL PRIMARY KEY,   
    FullDate DATE NOT NULL,
    DayNumber INT,
    MonthNumber INT,
    MonthName NVARCHAR(20),
    QuarterNumber INT,
    YearNumber INT
);

CREATE TABLE DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NCHAR(5) NOT NULL,
    CompanyName NVARCHAR(100),
    ContactName NVARCHAR(100),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    Country NVARCHAR(50)
);

CREATE TABLE DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(100),
    CategoryName NVARCHAR(100),
    SupplierName NVARCHAR(100),
    QuantityPerUnit NVARCHAR(50),
    Discontinued BIT
);


CREATE TABLE DimEmployee (
    EmployeeKey INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    FullName NVARCHAR(100),
    Title NVARCHAR(100),
    City NVARCHAR(50),
    Country NVARCHAR(50),
    HireDate DATE
);



CREATE TABLE FactSales (
    SalesKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    DateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    EmployeeKey INT NOT NULL,

    OrderID INT NOT NULL,
    ProductID INT NOT NULL,

    Quantity SMALLINT NOT NULL,
    UnitPrice MONEY NOT NULL,
    Discount REAL NOT NULL,
    Freight MONEY NULL,

    GrossSales AS (Quantity * UnitPrice) PERSISTED,
    DiscountAmount AS (Quantity * UnitPrice * Discount) PERSISTED,
    NetSales AS (Quantity * UnitPrice * (1 - Discount)) PERSISTED,

    CONSTRAINT FK_FactSales_DimDate
        FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),

    CONSTRAINT FK_FactSales_DimCustomer
        FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),

    CONSTRAINT FK_FactSales_DimProduct
        FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),

    CONSTRAINT FK_FactSales_DimEmployee
        FOREIGN KEY (EmployeeKey) REFERENCES DimEmployee(EmployeeKey)
);
