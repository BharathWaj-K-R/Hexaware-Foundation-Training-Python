-- SET 2 - BANK LOAN PORTFOLIO
-- ============================================================
/*
Expected tables:
Branches(BranchID, BranchName, City)
Customers(CustomerID, CustomerName)
Employees(EmployeeID, EmployeeName, BranchID, SupervisorID)
Loans(LoanID, CustomerID, BranchID, EmployeeID, LoanAmount, LoanDate, Status)
LoanMembers(LoanID, CustomerID, MemberRole) -- borrower/co-borrower/guarantor
Repayments(RepaymentID, LoanID, PaymentDate, Amount, Status)
*/

-- 1. Loans overdue by more than three instalments.
-- Assumption: a repayment row with Status='OVERDUE' represents one overdue instalment.
SELECT l.LoanID, c.CustomerName, l.LoanAmount,
       COUNT(r.RepaymentID) AS OverdueInstalments
FROM Loans AS l
INNER JOIN Customers AS c ON c.CustomerID = l.CustomerID
INNER JOIN Repayments AS r ON r.LoanID = l.LoanID
WHERE r.Status = 'OVERDUE'
GROUP BY l.LoanID, c.CustomerName, l.LoanAmount
HAVING COUNT(r.RepaymentID) > 3;

-- 1. Customers with loans in more than one branch.
SELECT c.CustomerID, c.CustomerName, COUNT(DISTINCT l.BranchID) AS BranchCount
FROM Customers AS c
INNER JOIN Loans AS l ON l.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName
HAVING COUNT(DISTINCT l.BranchID) > 1;

-- 1. Guarantors who are also borrowers (self-join through LoanMembers).
SELECT DISTINCT g.CustomerID, guarantor.CustomerName
FROM LoanMembers AS g
INNER JOIN LoanMembers AS b
    ON b.CustomerID = g.CustomerID
   AND b.MemberRole = 'BORROWER'
INNER JOIN Customers AS guarantor ON guarantor.CustomerID = g.CustomerID
WHERE g.MemberRole = 'GUARANTOR';

-- 1. Employees who report to supervisors (self-join).
SELECT e.EmployeeID, e.EmployeeName,
       s.EmployeeID AS SupervisorID, s.EmployeeName AS SupervisorName
FROM Employees AS e
INNER JOIN Employees AS s ON s.EmployeeID = e.SupervisorID;

-- 2. Correlated subquery: customers whose total loan exposure exceeds their branch average.
-- Compare each customer's total exposure in a branch with the average customer exposure in that branch.
WITH CustomerBranchExposure AS (
    SELECT l.BranchID, l.CustomerID, SUM(l.LoanAmount) AS TotalExposure
    FROM Loans AS l
    GROUP BY l.BranchID, l.CustomerID
)
SELECT x.BranchID, x.CustomerID, x.TotalExposure
FROM CustomerBranchExposure AS x
WHERE x.TotalExposure > (
    SELECT AVG(CAST(y.TotalExposure AS DECIMAL(18,2)))
    FROM CustomerBranchExposure AS y
    WHERE y.BranchID = x.BranchID
);

-- 2. Uncorrelated subquery: customers whose total exposure exceeds the average branch-level customer exposure.
WITH CustomerExposure AS (
    SELECT CustomerID, SUM(LoanAmount) AS TotalExposure
    FROM Loans
    GROUP BY CustomerID
)
SELECT CustomerID, TotalExposure
FROM CustomerExposure
WHERE TotalExposure > (SELECT AVG(CAST(TotalExposure AS DECIMAL(18,2))) FROM CustomerExposure);

-- 3. EXISTS: customers who have at least one loan.
SELECT c.CustomerID, c.CustomerName
FROM Customers AS c
WHERE EXISTS (
    SELECT 1 FROM Loans AS l WHERE l.CustomerID = c.CustomerID
);

-- 3. NOT EXISTS: customers who have no repayment in the last 60 days.
SELECT c.CustomerID, c.CustomerName
FROM Customers AS c
WHERE EXISTS (SELECT 1 FROM Loans l WHERE l.CustomerID = c.CustomerID)
AND NOT EXISTS (
    SELECT 1
    FROM Loans AS l
    INNER JOIN Repayments AS r ON r.LoanID = l.LoanID
    WHERE l.CustomerID = c.CustomerID
      AND r.PaymentDate >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
      AND r.PaymentDate <= CAST(GETDATE() AS DATE)
      AND r.Status = 'PAID'
);

-- 4. Nested subquery: branches whose highest individual loan is greater than
-- the bank-wide average of each branch's maximum loan.
WITH BranchMaximums AS (
    SELECT BranchID, MAX(LoanAmount) AS HighestLoan
    FROM Loans
    GROUP BY BranchID
)
SELECT b.BranchID, b.BranchName, bm.HighestLoan
FROM Branches AS b
INNER JOIN BranchMaximums AS bm ON bm.BranchID = b.BranchID
WHERE bm.HighestLoan > (
    SELECT AVG(CAST(inner_bm.HighestLoan AS DECIMAL(18,2)))
    FROM (
        SELECT BranchID, MAX(LoanAmount) AS HighestLoan
        FROM Loans
        GROUP BY BranchID
    ) AS inner_bm
);

-- ============================================================
