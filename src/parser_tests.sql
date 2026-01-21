-- -- Using a subquery that uses the MAX() function

-- SELECT 
--     productid, productname, unitprice
-- FROM
--     products
-- WHERE
--     unitprice = (SELECT MAX(unitprice) FROM products);

-- --Will be equal to

-- SELECT 
--     productid, productname, unitprice
-- FROM
--     products
-- WHERE
--     unitprice = 263.50;

-- SELECT 
--     AVG(unitprice)
-- FROM
--     products;

-- SELECT 
--     AVG(unitprice) AS 'avg unit price'
-- FROM
--     products;
	
-- -- Using a subquery that uses the AVG() function
-- SELECT 
--     productid, productname, unitprice
-- FROM
--     products
-- WHERE
--     unitprice > (SELECT AVG(unitprice) FROM products);

-- --Will be equal to

-- SELECT 
--     productid, productname, unitprice
-- FROM
--     products
-- WHERE
--     unitprice > 28.8663;

-- 	SELECT CompanyName, city
--   FROM Suppliers  
--   WHERE Country = 'USA'  
--   ORDER BY CompanyName; 

-- --Using BETWEEN operator
-- SELECT * FROM Employees 
-- WHERE EmployeeID BETWEEN 1 AND 5

-- --Using IN operator

-- SELECT * FROM Employees 
-- WHERE EmployeeID IN (1,2,3)

-- --Using LIKE operator

-- SELECT * FROM Employees 
-- WHERE FirstName LIKE 'Robert'

-- SELECT FirstName, BirthDate FROM Employees
-- ORDER BY BirthDate DESC

-- --First sort by BD, then by First name
-- SELECT FirstName, BirthDate FROM Employees
-- ORDER BY BirthDate DESC,
-- FirstName ASC;

-- SELECT ProductName,UnitPrice FROM Products 
-- GROUP BY ProductName, UnitPrice
-- HAVING AVG(UnitPrice)>20

-- SELECT * FROM Products 

-- SELECT ProductName,UnitPrice FROM Products 

-- --a simple expression:
-- SELECT 1 + 1

-- --combine string using CONCAT()
-- SELECT CONCAT(LastName,', ',FirstName) AS fullname
-- FROM employees


-- use employee_db
-- go

-- CREATE TABLE EmployeeMaster
-- (
-- 	  Id INT IDENTITY PRIMARY KEY,      
-- 	  EmployeeCode varchar(10),
-- 	  EmployeeName varchar(25),
--       DepartmentCode varchar(10),
--       LocationCode varchar(10),
--       salary int
-- );

-- TRUNCATE TABLE EmployeeMaster;
-- GO


-- INSERT INTO EmployeeMaster(EmployeeCode, EmployeeName, DepartmentCode, LocationCode ,salary)
-- VALUES
-- ('E0001', 'Hulk', 'IT','TVM', 4000),
-- ('E0002', 'Spiderman', 'IT','TVM',  4000),
-- ('E0003', 'Ironman', 'QA','KLM', 3000),
-- ('E0004', 'Superman', 'QA','KLM', 3000),
-- ('E0005', 'Batman', 'HR','TVM', 5000),
-- ('E0005', 'Raju', 'HR','KTM', 5000),
-- ('E0005', 'Radha', 'HR','KTM', 5000)



SELECT * FROM EmployeeMaster WHERE salary IS NOT NULL ;

-- SELECT * FROM EmployeeMaster WHERE salary IS NULL ;

-- SELECT * FROM EmployeeMaster WHERE employeename LIKE 'super'

-- SELECT * FROM EmployeeMaster WHERE employeename LIKE 'super''\\\\AZ\
-- c'

-- SELECT * FROM EmployeeMaster WHERE employeename LIKE 'super''\\\\AZ
-- c'

-- SELECT * FROM EmployeeMaster WHERE employeename LIKE 'sup%'

-- SELECT * FROM EmployeeMaster WHERE employeename LIKE '%man'


-- SELECT * FROM EmployeeMaster WHERE employeename NOT LIKE '%ra%'

-- /*will return 8 letter names starting with Su, containing p or j in between and ending in erman*/
-- SELECT * FROM EmployeeMaster WHERE employeename LIKE 'Su[pj]erman%'

-- /*will return 4 letter names starting with ra, containing n or j in between and ending in u*/
-- SELECT * FROM EmployeeMaster WHERE employeename LIKE 'ra[nj]u%'

-- /*will return 4 letter names starting with ra, NOT containing n or j in between and ending in u*/
-- SELECT * FROM EmployeeMaster WHERE employeename LIKE 'ra[^nj]u%'

-- select * from EmployeeMaster WHERE employeename NOT LIKE 'raj%'

-- SELECT * FROM EmployeeMaster WHERE EXISTS
-- (SELECT * FROM EmployeeMaster WHERE EmployeeName  LIKE 'superman')



-- SELECT trainee.admission_no, trainee.first_name, trainee.last_name, fee.course, fee.amount  
-- FROM trainee  
-- INNER JOIN fee ON trainee.admission_no = fee.admission_no; 

-- SELECT trainee.admission_no, trainee.first_name, trainee.last_name, fee.course, fee.amount, semester.sem_name 
-- FROM trainee  
-- INNER JOIN fee ON trainee.admission_no = fee.admission_no
-- INNER JOIN semester ON semester.sem_no = fee.sem_no  

-- SELECT trainee.admission_no, trainee.first_name, trainee.last_name, fee.course, fee.amount  
-- FROM trainee  
-- LEFT OUTER JOIN fee ON trainee.admission_no = fee.admission_no; 

-- SELECT trainee.admission_no, trainee.first_name, trainee.last_name, fee.course, fee.amount  
-- FROM trainee  
-- RIGHT OUTER JOIN fee ON trainee.admission_no = fee.admission_no;

-- SELECT trainee.admission_no, trainee.first_name, trainee.last_name, fee.course, fee.amount  
-- FROM trainee  
-- FULL OUTER JOIN fee ON trainee.admission_no = fee.admission_no;










-- IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='TRACKING' AND xtype='U')

-- BEGIN

-- CREATE TABLE dbo.TRACKING (
--     TRACKING_KEY INT NOT NULL,
--     C_KEY INT NULL,
--     USER_KEY INT NULL,
--     ACTION_DATETIME DATE NULL,
--     SOURCE NVARCHAR(20) NULL,
--     [ACTION] NVARCHAR(20) NULL,
--     [DESC] NVARCHAR(100) NULL,
--     CONSTRAINT PK_TRACKING
--         PRIMARY KEY CLUSTERED (TRACKING_KEY)
-- )

-- INSERT INTO TRACKING (
--         [TRACKING_KEY],
--         [C_KEY],
--         [USER_KEY],
--         [ACTION_DATETIME],
--         [SOURCE],
--         [ACTION],
--         [DESC]
--     )
--     VALUES (
--         -1,
--         -1,   
--         -1,  
--         NULL,
--         '-',
--         'OTHER',
--         '-' 
--     )

-- END
-- GO


-- INSERT INTO TRACKING
-- (
--     [TRACKING_KEY],
--     C_KEY,
--     USER_KEY,
--     ACTION_DATETIME,
--     [SOURCE],
--     [ACTION],
--     [DESC]
-- )
-- SELECT
--     [STG_TRACKING].[TRACKING_KEY],
--     [STG_TRACKING].[C_KEY],
--     [STG_TRACKING].USER_KEY,
--     [STG_TRACKING].ACTION_DATETIME,
--     [STG_TRACKING].SOURCE,
--     [STG_TRACKING].[ACTION],
--     [STG_TRACKING].[DESC]
-- FROM [STG_TRACKING]
-- INNER JOIN [USERS]
--     ON [USERS].USER_KEY = [STG_TRACKING].USER_KEY AND [USERS].[GROUP_KEY] IN (11,2,3,4)
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM TRACKING 
--     WHERE TRACKING.[TRACKING_KEY] = [STG_TRACKING].[TRACKING_KEY]
-- )

-- GO


-- SELECT EmployeeName 
-- FROM Employees 
-- WHERE EXISTS (
--     SELECT 1 
--     FROM SalaryPayments 
--     WHERE SalaryPayments.EmployeeID = Employees.ID
-- );

-- IF NOT EXISTS (SELECT * FROM Customers WHERE Email = 'test@example.com')
-- BEGIN
--     INSERT INTO Customers (CustomerName, Email) 
--     VALUES ('New Customer', 'test@example.com');
-- END

-- SELECT * FROM Products 
-- WHERE Price > 100 
-- AND EXISTS (
--     SELECT * FROM Inventory 
--     WHERE Inventory.ProductID = Products.ID 
--     AND Quantity > 0
-- );