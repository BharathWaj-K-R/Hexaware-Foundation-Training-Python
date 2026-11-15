-- SET 1 - LOGISTICS SHIPMENT ANALYSIS
-- ============================================================
/*
Expected tables:
Hubs(HubID, HubName, City)
Carriers(CarrierID, CarrierName)
Employees(EmployeeID, EmployeeName, SupervisorID)
Shipments(ShipmentID, CustomerID, HubID, CarrierID, EmployeeID, ShipDate, DeliveryDate, Status, DelayDays)
DeliveryEvents(EventID, ShipmentID, EventDate, EventType, Notes)
*/

-- 1. INNER JOIN: shipments delayed by more than two days, with carrier names.
SELECT s.ShipmentID, c.CarrierName, s.DelayDays, s.Status
FROM Shipments AS s
INNER JOIN Carriers AS c ON c.CarrierID = s.CarrierID
WHERE s.DelayDays > 2;

-- 1. LEFT JOIN: hubs with no outbound shipments.
SELECT h.HubID, h.HubName
FROM Hubs AS h
LEFT JOIN Shipments AS s ON s.HubID = h.HubID
WHERE s.ShipmentID IS NULL;

-- 1. FULL OUTER JOIN: employees and their supervisors, retaining unmatched employees/supervisors.
SELECT e.EmployeeID, e.EmployeeName,
       sup.EmployeeID AS SupervisorID, sup.EmployeeName AS SupervisorName
FROM Employees AS e
FULL OUTER JOIN Employees AS sup ON sup.EmployeeID = e.SupervisorID;

-- 2. IN: customers who shipped through every hub.
-- A customer qualifies when the number of distinct hubs used equals the total number of hubs.
SELECT DISTINCT s.CustomerID
FROM Shipments AS s
WHERE s.HubID IN (SELECT h.HubID FROM Hubs AS h)
GROUP BY s.CustomerID
HAVING COUNT(DISTINCT s.HubID) = (SELECT COUNT(*) FROM Hubs);

-- 2. EXISTS: carriers whose average delay is above the overall shipment average.
SELECT c.CarrierID, c.CarrierName
FROM Carriers AS c
WHERE EXISTS (
    SELECT 1
    FROM Shipments AS s
    WHERE s.CarrierID = c.CarrierID
    GROUP BY s.CarrierID
    HAVING AVG(CAST(s.DelayDays AS DECIMAL(10,2))) >
           (SELECT AVG(CAST(DelayDays AS DECIMAL(10,2))) FROM Shipments)
);

-- 2. ANY: carriers with at least one shipment delay greater than at least one hub's average delay.
SELECT c.CarrierID, c.CarrierName
FROM Carriers AS c
WHERE (SELECT MAX(s.DelayDays)
       FROM Shipments AS s
       WHERE s.CarrierID = c.CarrierID)
      > ANY (
          SELECT AVG(CAST(s2.DelayDays AS DECIMAL(10,2)))
          FROM Shipments AS s2
          GROUP BY s2.HubID
      );

-- 2. ALL: carriers whose average delay is greater than every hub's average delay.
SELECT c.CarrierID, c.CarrierName
FROM Carriers AS c
WHERE (SELECT AVG(CAST(s.DelayDays AS DECIMAL(10,2)))
       FROM Shipments AS s
       WHERE s.CarrierID = c.CarrierID)
      > ALL (
          SELECT AVG(CAST(s2.DelayDays AS DECIMAL(10,2)))
          FROM Shipments AS s2
          GROUP BY s2.HubID
      );

-- 3. Rewrite a correlated EXISTS subquery as a JOIN.
-- JOIN version of "carriers whose average delay is above the overall average".
SELECT c.CarrierID, c.CarrierName, AVG(CAST(s.DelayDays AS DECIMAL(10,2))) AS AverageDelay
FROM Carriers AS c
INNER JOIN Shipments AS s ON s.CarrierID = c.CarrierID
GROUP BY c.CarrierID, c.CarrierName
HAVING AVG(CAST(s.DelayDays AS DECIMAL(10,2))) >
       (SELECT AVG(CAST(DelayDays AS DECIMAL(10,2))) FROM Shipments);
-- Readability: JOIN is convenient when carrier details and shipment aggregates are needed.
-- EXISTS is convenient when only existence/qualification matters and avoids grouping outer rows.

-- 4. Nested subquery: shipments whose delay is greater than the average delay of their own hub.
SELECT s.ShipmentID, s.HubID, s.DelayDays
FROM Shipments AS s
WHERE s.DelayDays > (
    SELECT AVG(CAST(s2.DelayDays AS DECIMAL(10,2)))
    FROM Shipments AS s2
    WHERE s2.HubID = s.HubID
);

-- ============================================================
