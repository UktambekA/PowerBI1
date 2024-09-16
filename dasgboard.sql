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
