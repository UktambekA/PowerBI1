--Umimiy buyurtmalar va moliyaviy ma'lumotlar

SELECT 
    COUNT(SalesOrderID) AS TotalOrders,
    SUM(SubTotal) AS TotalSubTotal,
    SUM(TaxAmt) AS TotalTax,
    SUM(Freight) AS TotalFreight,
    SUM(TotalDue) AS TotalDue
FROM Sales.SalesOrderHeader


--Yetkazib berish usuli bo'yicha buyurtmalar:
SELECT 
    ShipMethod,
    COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY ShipMethod


--Online/Offline buyurtmalar:
SELECT 
    CASE WHEN OnlineOrderFlag = 1 THEN 'Online' ELSE 'Offline' END AS OrderType,
    COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag



--Hudud bo'yicha buyurtmalar va summa:
SELECT 
    st.Name AS Territory,
    COUNT(soh.SalesOrderID) AS OrderCount,
    SUM(soh.TotalDue) AS TotalDue
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY st.Name


--Vaqt bo'yicha buyurtmalar trendi:
SELECT 
    CAST(OrderDate AS DATE) AS OrderDate,
    CAST(ShipDate AS DATE) AS ShipDate,
    CAST(DueDate AS DATE) AS DueDate,
    COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY CAST(OrderDate AS DATE), CAST(ShipDate AS DATE), CAST(DueDate AS DATE)



--Mahsulot kategoriyasi bo'yicha buyurtmalar:
SELECT 
    pc.Name AS Category,
    COUNT(DISTINCT soh.SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY OrderCount DESC

--Oylar bo'yicha sotuv

SELECT 
    YEAR(OrderDate) AS [Year],
    MONTH(OrderDate) AS [Month], 
    DATENAME(MONTH, OrderDate) AS [MonthName],
    SUM(TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader
WHERE 
    YEAR(OrderDate) BETWEEN 2011 AND 2014
GROUP BY 
    YEAR(OrderDate), MONTH(OrderDate), DATENAME(MONTH, OrderDate)
ORDER BY 
    [Year], [Month];


--totalsales territory


SELECT 
    st.Name AS TerritoryName,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY 
    st.Name
ORDER BY 
    TotalSales DESC;



WITH CustomerSales AS (
    SELECT 
        CustomerID,
        SUM(TotalDue) AS TotalSales,
        COUNT(DISTINCT SalesOrderID) AS OrderCount
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        CustomerID
)
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue,
    soh.CustomerID,
    cs.TotalSales AS CustomerLifetimeValue,
    cs.OrderCount AS CustomerOrderCount,
    soh.SalesPersonID,
    sp.SalesQuota,
    st.TerritoryID,
    st.Name AS TerritoryName,
    st.CountryRegionCode,
    st.[Group] AS SalesTerritoryGroup,
    p.ProductID,
    p.Name AS ProductName,
    p.StandardCost,
    p.ListPrice,
    pc.Name AS CategoryName,
    ps.Name AS SubcategoryName,
    sod.OrderQty,
    sod.UnitPrice,
    sod.LineTotal,
    sod.UnitPriceDiscount,
    YEAR(soh.OrderDate) AS OrderYear,
    MONTH(soh.OrderDate) AS OrderMonth,
    DATENAME(weekday, soh.OrderDate) AS OrderDayOfWeek,
    DATEDIFF(day, soh.OrderDate, soh.ShipDate) AS DaysToShip
FROM 
    Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    LEFT JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
    JOIN CustomerSales cs ON soh.CustomerID = cs.CustomerID