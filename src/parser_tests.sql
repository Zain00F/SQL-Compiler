-- Update rows based on a list from a subquery
UPDATE Production.Product SET DiscontinuedDate = 5 
WHERE ProductID IN (SELECT ProductID FROM Sales.SalesOrderDetail WHERE LineTotal > 10000);