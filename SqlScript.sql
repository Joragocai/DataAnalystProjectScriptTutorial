USE SqlTutorial;

SELECT * 
FROM EmployeeDemographics;

WITH CTE_Employee AS
(
SELECT FirstName, LastName, Gender, Salary,
COUNT(Gender) OVER (PARTITION BY Gender) AS count_gender
FROM EmployeeDemographics AS Demo
JOIN EmployeeSalary AS Sal
	ON Demo.EmployeeID = Sal.EmployeeID
    )
    
SELECT * FROM CTE_Employee;

CREATE TEMPORARY TABLE temp_Employee
(EmployeeID int,
FirstName VARCHAR(50),
LastName VARCHAR(50),
Age int,
Gender VARCHAR(50));

SELECT * 
FROM temp_Employee;

INSERT INTO temp_Employee VALUES
(6969, 'John', 'Adams',70,'Male');

INSERT INTO temp_Employee
SELECT * 
FROM EmployeeDemographics;

DROP TABLE IF EXISTS temp_Employee2;
CREATE TEMPORARY TABLE temp_Employee2
(JobTitle VARCHAR(50),
EmployeesPerJob int,
AvgAge int,
AvgSalary int)

SELECT * 
FROM temp_Employee2;

INSERT INTO temp_Employee2 
SELECT JobTitle, COUNT(JobTitle), AVG(Age), AVG(Salary)
FROM EmployeeDemographics AS Demo
JOIN EmployeeSalary AS Sal
	ON Demo.EmployeeID = Sal.EmployeeID
GROUP BY JobTitle;

SELECT *, trim(EmployeeID) AS id_trim 
FROM EmployeeErrors;

SELECT EmployeeID, LTRIM(EmployeeID) AS id_trim 
FROM EmployeeErrors;

SELECT EmployeeID, RTRIM(EmployeeID) AS id_trim 
FROM EmployeeErrors;

SELECT * 
FROM EmployeeErrors;

SELECT LastName, REPLACE(LastName,'- Fired','')  
FROM EmployeeErrors;

SELECT LastName, REPLACE(LastName,'- Fired','') AS replace_lastname 
FROM EmployeeErrors;

SELECT SUBSTRING(FirstName, 1, 3) AS subFirstName 
FROM EmployeeErrors;

SELECT SUBSTRING(err.FirstName, 1, 3), SUBSTRING(demo.FirstName, 1, 3)
FROM EmployeeErrors err
JOIN EmployeeDemographics demo
	ON SUBSTRING(err.FirstName, 1, 3) = SUBSTRING(demo.FirstName, 1, 3);

SELECT err.FirstName, demo.FirstName
FROM EmployeeErrors err
JOIN EmployeeDemographics demo
	ON SUBSTRING(err.FirstName, 1, 3) = SUBSTRING(demo.FirstName, 1, 3);

SELECT UPPER(FirstName), LOWER(LastName)
FROM EmployeeErrors;

DELIMITER //
CREATE PROCEDURE TEST()
BEGIN
	SELECT * FROM EmployeeDemographics;
END //
DELIMITER ;

CALL TEST();


