-- Using a subquery that uses the MAX() function

SELECT 
    productid, productname, unitprice
FROM
    products
WHERE
    unitprice = (SELECT MAX(unitprice) FROM products);

--Will be equal to

SELECT 
    productid, productname, unitprice
FROM
    products
WHERE
    unitprice = 263.50;

SELECT 
    AVG(unitprice)
FROM
    products;


SELECT 
    AVG(unitprice) AS 'avg unit price'
FROM
    products;
	
-- Using a subquery that uses the AVG() function

SELECT 
    productid, productname, unitprice
FROM
    products
WHERE
    unitprice > (SELECT AVG(unitprice) FROM products);

--Will be equal to

SELECT 
    productid, productname, unitprice
FROM
    products
WHERE
    unitprice > 28.8663;



	SELECT CompanyName, city
  FROM Suppliers  
  WHERE Country = 'USA'  
  ORDER BY CompanyName; 

--Using BETWEEN operator
SELECT * FROM Employees 
WHERE EmployeeID BETWEEN 1 AND 5

--Using IN operator
SELECT * FROM Employees 
WHERE EmployeeID IN (1,2,3)

--Using LIKE operator
SELECT * FROM Employees 
WHERE FirstName Like 'Robert'

SELECT FirstName, BirthDate FROM Employees
ORDER BY BirthDate DESC

--First sort by BD, then by First name
SELECT FirstName, BirthDate FROM Employees
ORDER BY BirthDate DESC,
FirstName ASC;

SELECT ProductName,UnitPrice FROM Products 
GROUP BY ProductName, UnitPrice
HAVING AVG(UnitPrice)>20

SELECT * FROM Products 

SELECT ProductName,UnitPrice FROM Products 

--a simple expression:
SELECT 1 + 1

--combine string using CONCAT()
SELECT CONCAT(LastName,', ',FirstName) AS fullname
FROM employees

use employee_db
go
CREATE TABLE EmployeeMaster
(
	  Id INT IDENTITY PRIMARY KEY,      
	  EmployeeCode varchar(10),
	  EmployeeName varchar(25),
      DepartmentCode varchar(10),
      LocationCode varchar(10),
      salary int
)

TRUNCATE TABLE EmployeeMaster;
GO;



INSERT into EmployeeMaster(EmployeeCode, EmployeeName, DepartmentCode, LocationCode ,salary)
VALUES
('E0001', 'Hulk', 'IT','TVM', 4000),
('E0002', 'Spiderman', 'IT','TVM',  4000),
('E0003', 'Ironman', 'QA','KLM', 3000),
('E0004', 'Superman', 'QA','KLM', 3000),
('E0005', 'Batman', 'HR','TVM', 5000),
('E0005', 'Raju', 'HR','KTM', 5000),
('E0005', 'Radha', 'HR','KTM', 5000)



SELECT * from EmployeeMaster WHERE salary IS NOT NULL

SELECT * from EmployeeMaster WHERE salary IS NULL

SELECT * from EmployeeMaster WHERE employeename LIKE 'super'

SELECT * from EmployeeMaster WHERE employeename LIKE 'super''\\\\AZ\
c'

SELECT * from EmployeeMaster WHERE employeename LIKE 'super''\\\\AZ
c'

SELECT * from EmployeeMaster WHERE employeename LIKE 'sup%'

SELECT * from EmployeeMaster WHERE employeename LIKE '%man'

SELECT * from EmployeeMaster WHERE employeename NOT LIKE '%ra%'

/*will return 8 letter names starting with Su, containing p or j in between and ending in erman*/
SELECT * from EmployeeMaster WHERE employeename LIKE 'Su[pj]erman%'

/*will return 4 letter names starting with ra, containing n or j in between and ending in u*/
SELECT * from EmployeeMaster WHERE employeename LIKE 'ra[nj]u%'

/*will return 4 letter names starting with ra, NOT containing n or j in between and ending in u*/
SELECT * from EmployeeMaster WHERE employeename LIKE 'ra[^nj]u%'

SELECT * from EmployeeMaster WHERE employeename NOT LIKE 'raj%'

select * from EmployeeMaster WHERE EXISTS
(select * from EmployeeMaster where EmployeeName  LIKE 'superman')



SELECT trainee.admission_no, trainee.first_name, trainee.last_name, fee.course, fee.amount  
FROM trainee  
INNER JOIN fee ON trainee.admission_no = fee.admission_no; 

SELECT trainee.admission_no, trainee.first_name, trainee.last_name, fee.course, fee.amount, semester.sem_name 
FROM trainee  
INNER JOIN fee ON trainee.admission_no = fee.admission_no
INNER JOIN semester ON semester.sem_no = fee.sem_no  

SELECT trainee.admission_no, trainee.first_name, trainee.last_name, fee.course, fee.amount  
FROM trainee  
LEFT OUTER JOIN fee ON trainee.admission_no = fee.admission_no; 

SELECT trainee.admission_no, trainee.first_name, trainee.last_name, fee.course, fee.amount  
FROM trainee  
RIGHT OUTER JOIN fee ON trainee.admission_no = fee.admission_no;

SELECT trainee.admission_no, trainee.first_name, trainee.last_name, fee.course, fee.amount  
FROM trainee  
FULL OUTER JOIN fee ON trainee.admission_no = fee.admission_no;