-- SET 3 - RETAIL RETURNS AND REFUNDS
-- ============================================================
/*
Expected tables:
Stores(StoreID, StoreName, Region)
Customers(CustomerID, CustomerName)
Products(ProductID, ProductName, Category, UnitPrice)
Employees(EmployeeID, EmployeeName, StoreID, SupervisorID)
Orders(OrderID, CustomerID, StoreID, OrderDate)
OrderItems(OrderItemID, OrderID, ProductID, Quantity, UnitPrice)
Returns(ReturnID, OrderItemID, ReturnDate, ReturnReason, RefundAmount, Status)
*/

-- 1. Products with a return rate above 10%.
-- Return rate = returned quantity/ordered quantity. Assumption: one Returns row represents one returned unit.
SELECT p.ProductID, p.ProductName,
       CAST(COUNT(r.ReturnID) AS DECIMAL(10,2)) /
       NULLIF(SUM(oi.Quantity), 0) * 100 AS ReturnRatePercent
FROM Products AS p
INNER JOIN OrderItems AS oi ON oi.ProductID = p.ProductID
LEFT JOIN Returns AS r ON r.OrderItemID = oi.OrderItemID
GROUP BY p.ProductID, p.ProductName
HAVING CAST(COUNT(r.ReturnID) AS DECIMAL(10,2)) /
       NULLIF(SUM(oi.Quantity), 0) > 0.10;

-- 1. Customers with returns but no refund.
SELECT DISTINCT c.CustomerID, c.CustomerName
FROM Customers AS c
INNER JOIN Orders AS o ON o.CustomerID = c.CustomerID
INNER JOIN OrderItems AS oi ON oi.OrderID = o.OrderID
INNER JOIN Returns AS r ON r.OrderItemID = oi.OrderItemID
WHERE r.RefundAmount IS NULL OR r.RefundAmount = 0;

-- 1. Stores with the highest return value.
SELECT TOP (1) WITH TIES s.StoreID, s.StoreName,
       SUM(r.RefundAmount) AS TotalRefundValue
FROM Stores AS s
INNER JOIN Orders AS o ON o.StoreID = s.StoreID
INNER JOIN OrderItems AS oi ON oi.OrderID = o.OrderID
INNER JOIN Returns AS r ON r.OrderItemID = oi.OrderItemID
GROUP BY s.StoreID, s.StoreName
ORDER BY SUM(r.RefundAmount) DESC;

-- 1. Employees with their managers (self-join).
SELECT e.EmployeeID, e.EmployeeName,
       m.EmployeeID AS ManagerID, m.EmployeeName AS ManagerName
FROM Employees AS e
LEFT JOIN Employees AS m ON m.EmployeeID = e.SupervisorID;

-- 2. NOT IN: customers who have not made any return.
-- NOT IN can behave unexpectedly if its subquery returns NULL; CustomerID is assumed NOT NULL.
SELECT c.CustomerID, c.CustomerName
FROM Customers AS c
WHERE c.CustomerID NOT IN (
    SELECT o.CustomerID
    FROM Orders AS o
    INNER JOIN OrderItems AS oi ON oi.OrderID = o.OrderID
    INNER JOIN Returns AS r ON r.OrderItemID = oi.OrderItemID
    WHERE o.CustomerID IS NOT NULL
);

-- 2. NULL pitfall: unsafe NOT IN example and safe correction.
-- Unsafe if the subquery can return NULL:
-- SELECT CustomerID FROM Customers
-- WHERE CustomerID NOT IN (SELECT CustomerID FROM Orders);
-- Safer NOT EXISTS:
SELECT c.CustomerID, c.CustomerName
FROM Customers AS c
WHERE NOT EXISTS (
    SELECT 1 FROM Orders AS o
    INNER JOIN OrderItems AS oi ON oi.OrderID = o.OrderID
    INNER JOIN Returns AS r ON r.OrderItemID = oi.OrderItemID
    WHERE o.CustomerID = c.CustomerID
);

-- 3. ANY: stores whose refund total is greater than at least one other store's refund total.
WITH StoreRefunds AS (
    SELECT s.StoreID, s.StoreName, COALESCE(SUM(r.RefundAmount), 0) AS RefundTotal
    FROM Stores AS s
    LEFT JOIN Orders o ON o.StoreID = s.StoreID
    LEFT JOIN OrderItems oi ON oi.OrderID = o.OrderID
    LEFT JOIN Returns r ON r.OrderItemID = oi.OrderItemID
    GROUP BY s.StoreID, s.StoreName
)
SELECT StoreID, StoreName, RefundTotal
FROM StoreRefunds
WHERE RefundTotal > ANY (
    SELECT RefundTotal FROM StoreRefunds
    WHERE StoreID <> StoreRefunds.StoreID
);

-- 3. ALL: stores whose refund total is greater than every other store's refund total.
WITH StoreRefunds AS (
    SELECT s.StoreID, s.StoreName, COALESCE(SUM(r.RefundAmount), 0) AS RefundTotal
    FROM Stores AS s
    LEFT JOIN Orders o ON o.StoreID = s.StoreID
    LEFT JOIN OrderItems oi ON oi.OrderID = o.OrderID
    LEFT JOIN Returns r ON r.OrderItemID = oi.OrderItemID
    GROUP BY s.StoreID, s.StoreName
)
SELECT sr.StoreID, sr.StoreName, sr.RefundTotal
FROM StoreRefunds AS sr
WHERE sr.RefundTotal > ALL (
    SELECT other_sr.RefundTotal
    FROM StoreRefunds AS other_sr
    WHERE other_sr.StoreID <> sr.StoreID
);

-- 4. Nested subquery: stores with refund totals above the regional average store refund total.
WITH StoreRefunds AS (
    SELECT s.StoreID, s.StoreName, s.Region,
           COALESCE(SUM(r.RefundAmount), 0) AS RefundTotal
    FROM Stores AS s
    LEFT JOIN Orders o ON o.StoreID = s.StoreID
    LEFT JOIN OrderItems oi ON oi.OrderID = o.OrderID
    LEFT JOIN Returns r ON r.OrderItemID = oi.OrderItemID
    GROUP BY s.StoreID, s.StoreName, s.Region
)
SELECT sr.StoreID, sr.StoreName, sr.Region, sr.RefundTotal
FROM StoreRefunds AS sr
WHERE sr.RefundTotal > (
    SELECT AVG(CAST(regional.RefundTotal AS DECIMAL(18,2)))
    FROM StoreRefunds AS regional
    WHERE regional.Region = sr.Region
);
