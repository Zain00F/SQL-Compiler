SELECT * FROM HumanResources.Employee
WHERE (VacationHours > 40 OR SickLeaveHours > 40)
AND SalariedFlag = 1;