# Library Management System

## Overview

The **Library Management System** is a relational database project developed using **MS SQL Server**. It is designed to manage library data efficiently, including tracking books, borrowers, and loans, while providing various querying capabilities for insights into library operations such as borrowing trends, overdue loans, and book availability.

## Objectives

- To create a robust database system for managing library operations.
- To enable efficient querying of borrowing trends, overdue loans, and book availability.
- To provide an intuitive interface for managing library data.

## Database Schema

### Entity-Relationship Model (ERM)

The database consists of three main entities:

- **Books**: Contains information about each book in the library.
- **Borrowers**: Stores details about the library members who borrow books.
- **Loans**: Tracks the borrowing activity, linking books and borrowers.

### Relational Schema

#### 1. Books Table

```sql
CREATE TABLE Books (
     Book_ID INT,
	 Title VARCHAR(300),
	 Author VARCHAR(255),
	 ISBN VARCHAR(13),
	 [Published Date] DATE,
	 Genre VARCHAR(100),
	 [Shelf Location] VARCHAR(15),
	 [Current Status] VARCHAR(9) CHECK([Current Status] IN ('Available', 'Borrowed')),
	 PRIMARY KEY (Book_ID)
);
```

#### 2. Borrowers Table

```sql
CREATE TABLE Borrowers (
     Borrower_ID INT,
	 [First Name] VARCHAR(35) NOT NULL,
	 [Last Name] VARCHAR(35) NOT NULL,
	 Email VARCHAR(270) NOT NULL UNIQUE,
	 [Date of Birth] DATE,
	 [Membership Date] DATE,
	 PRIMARY KEY (Borrower_ID)
);
```

#### 3. Loans Table

```sql
CREATE TABLE Loans (
     Loan_ID INT,
	 Borrower_ID INT,
	 Book_ID INT,
	 [Date Borrowed] DATE,
	 [Due Date] DATE,
	 [Date Returned] DATE,
	 PRIMARY KEY (Loan_ID),
	 FOREIGN KEY (Borrower_ID) REFERENCES Borrowers(Borrower_ID),
	 FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);
```

---

### **Rationale**:
- **Loan_ID**: It is the primary key of the Loans table and is auto-incremented to guarantee that each loan is uniquely identifiable.
- **Book_ID & Borrower_ID**: These fields are foreign keys linking to the Books and Borrowers tables respectively. The foreign key constraints maintain referential integrity, ensuring that only existing books and borrowers are involved in loans. The ON DELETE CASCADE for Borrower_ID removes associated loans if a borrower is deleted, while ON DELETE SET NULL for Book_ID allows a book to be removed without deleting the loan.
- **[Date Borrowed]**: This mandatory field represents the date when the book was borrowed.
- **[Due Date]**: This is the date the borrowed book should be returned. The constraint ensures that the due date is never set before the borrow date, preserving logical consistency.
- **[Date Returned]**: This field records when the book was returned, if applicable. The CHECK constraint allows it to be NULL if the book has not been returned yet, and if filled, the date must not precede the borrow date.
- **Constraints**: The **CHECK** constraints and foreign key settings ensure that all relationships between dates and tables are logical, preventing errors such as returning a book before borrowing it or having a loan associated with a nonexistent book or borrower.

---

## Data Seeding

To facilitate testing and demonstration, the database includes seeded data for:

- **1000 Books** with unique ISBNs, titles, authors, genres, and publication dates.
- **1000 Borrowers** with names, email addresses, and membership dates.
- **1000 Loan records** that detail borrowing relationships, loan dates, and return statuses.

The data seeding script is available in the `SeedingDMLs` directory of the repository.

## Advanced Queries and Procedures

This section provides examples of advanced SQL queries stored procedures, functions and triggers that enhance the functionality of the library system.


### **1. List of Borrowed Books**
```sql
DECLARE @ID INT = 7;

SELECT B.*, [Date Returned]
FROM Loans AS L INNER JOIN Books AS B ON L.Book_ID = B.Book_ID
WHERE L.Book_ID = @ID;
```
- **Rationale**: This query retrieves all books currently borrowed by a specific borrower that have not yet been returned.

---

### **2. Active Borrowers Report**
```sql
WITH CountBorrowedBooks(ID, BorrowedBooks) AS
(
    SELECT Borrower_ID, COUNT(*) AS BorrowedBooks
	FROM Loans
	GROUP BY Borrower_ID
	HAVING COUNT(*) >= 2
), 
CountBorrowedBooks_ReturnDateNULL(ID, BorrowedBooks) AS
(
    SELECT Borrower_ID, COUNT(CASE WHEN [Date Returned] IS NULL THEN 1 END) AS BorrowedBooks
	FROM Loans
	GROUP BY Borrower_ID
)
SELECT B.Borrower_ID AS ID, CONCAT([First Name], ' ', [Last Name]) AS [Name]
FROM  
CountBorrowedBooks AS X 
INNER JOIN 
CountBorrowedBooks_ReturnDateNULL AS Y 
ON  X.ID = Y.ID AND X.BorrowedBooks = Y.BorrowedBooks
INNER JOIN 
Borrowers AS B 
ON X.ID = B.Borrower_ID
ORDER BY B.Borrower_ID;
```
- **Rationale**: This query lists all borrowers who currently have two or more books that are still outstanding and have not been returned.

---

### **3. Book Borrowing Frequency Using Window Functions**
```sql
-- using CTE's & Window Functions & JOIN
WITH GroupsCount AS (
     SELECT Borrower_ID, COUNT(*) AS [Borrowing Frequency]
	 FROM Loans
	 GROUP BY Borrower_ID
)
SELECT B.Borrower_ID, [First Name], [Last Name], [Borrowing Frequency],
DENSE_RANK() OVER(ORDER BY [Borrowing Frequency] DESC) AS [Rank]
FROM Borrowers AS B INNER JOIN GroupsCount AS G ON B.Borrower_ID = G.Borrower_ID;
```
- **Rationale**: This query ranks borrowers based on the frequency of their borrowing activity, allowing the library to identify the most frequent borrowers.

---

### **4. Popular Genre Analysis Using Joins**
```sql
DECLARE @Month INT = 1;

WITH GroupsCount as (
     SELECT Genre, COUNT(*) AS [Number of Books Borrowed]
     FROM Loans AS L INNER JOIN Books AS B ON L.Book_ID = B.Book_ID
     WHERE Genre != '(no genres listed)' AND MONTH([Date Borrowed]) = @Month
     GROUP BY Genre
)
SELECT * FROM (
SELECT Genre, [Number of Books Borrowed], 
DENSE_RANK() OVER(ORDER BY [Number of Books Borrowed] DESC) AS [Rank]
FROM GroupsCount) AS X
WHERE [Rank] < 2;
```
- **Rationale**: This query analyzes the most borrowed genre during a specific month, providing insights into popular reading trends.

---

### **5. Stored Procedure - Add New Borrowers**
```sql
CREATE OR ALTER PROCEDURE sp_AddNewBorrower (
    @FirstName VARCHAR(35), 
    @LastName VARCHAR(35), 
    @Email VARCHAR(270), 
    @DateOfBirth DATE, 
    @MembershipDate DATE,
    @LastInsertedBorrowerID INT OUTPUT
)
AS
BEGIN
    IF EXISTS(SELECT Email FROM Borrowers WHERE Email = @Email)
    BEGIN
        RAISERROR('Email already exists!', 16, 1);
    END
	ELSE
	BEGIN
    INSERT INTO Borrowers VALUES (@FirstName, @LastName, @Email, @DateOfBirth, @MembershipDate);
    SET @LastInsertedBorrowerID = CONVERT(INT, SCOPE_IDENTITY());
	END
END;
```
- **Rationale**: This stored procedure ensures a new borrower is only added if their email address doesn't already exist in the system. If the insertion is successful, it returns the **Borrower_ID**.



---

### **6. Database Function - Calculate Overdue Fees**
```sql
CREATE FUNCTION fn_CalculateOverdueFees(@Loan_ID INT)
RETURNS INT
AS
BEGIN
     DECLARE @DueDate DATE;
	 SELECT @DueDate = [Due Date] FROM Loans WHERE Loan_ID = @Loan_ID;

	 DECLARE @ReturnDate DATE;
	 SELECT @ReturnDate = [Date Returned] FROM Loans WHERE Loan_ID = @Loan_ID;

	 DECLARE @Difference INT;

	 IF @ReturnDate IS NULL
	 BEGIN
        SET @Difference = DATEDIFF(DAY, @DueDate, GETDATE());
	 END
     ELSE
	 BEGIN
        SET @Difference = DATEDIFF(DAY, @DueDate, @ReturnDate);
	 END

	 IF @Difference < 0
     BEGIN
        RETURN 0;
     END

	 DECLARE @MinValue INT = CASE WHEN @Difference < 30 THEN @Difference ELSE 30 END;
	 DECLARE @Result INT = @MinValue;

	 SET @Difference = @Difference - @MinValue;
	 SET @Result = @Result + @Difference * 2;

	 RETURN @Result;
END;

SELECT CONCAT('$', dbo.fn_CalculateOverdueFees(Loan_ID)) AS [Overdue Fees]
FROM Loans;
```
- **Rationale**: This function calculates overdue fees based on how many days a book has been overdue. If the book is overdue for more than 30 days, the fine rate doubles.

---

### **7. Book Borrowing Frequency Function**
```sql
CREATE FUNCTION fn_BookBorrowingFrequency(@Book_ID INT)
RETURNS INT
BEGIN
     DECLARE @Result INT = 0;
     SELECT @Result = COUNT(*) FROM Loans WHERE Book_ID = @Book_ID;
	 RETURN @Result;
END;

SELECT * FROM Loans ORDER BY Book_ID;
SELECT dbo.fn_BookBorrowingFrequency(13);
```
- **Rationale**: This function calculates the total number of times a specific book has been borrowed, providing insight into its popularity.

---

### **8. Overdue Books Report**
```sql
SELECT B.Borrower_ID, CONCAT([First Name], ' ', [Last Name]) AS [Name],
Book_ID, [Date Borrowed], [Due Date], [Date Returned]
FROM Loans AS L INNER JOIN Borrowers AS B ON L.Borrower_ID = B.Borrower_ID
WHERE DATEADD(DAY, -30, ISNULL([Date Returned], GETDATE())) > [Due Date]
ORDER BY B.Borrower_ID;
```
- **Rationale**: This query lists all books that are overdue by more than 30 days, along with the details of the borrowers who have them, helping the library to manage overdue loans.

---

### **9. Author Popularity using Aggregation**
```sql
-- CTE'S,Join and Aggregation
WITH GroupsCount AS (
     SELECT Book_ID, COUNT(*) AS [Count]
	 FROM Loans
	 GROUP BY Book_ID
)
SELECT Author, SUM([Count]) AS [Books]
FROM Books AS B INNER JOIN GroupsCount AS G ON B.Book_ID = G.Book_ID
GROUP BY Author
ORDER BY [Books] DESC;




-- CTE'S,Join and Window Function
WITH GroupsCount AS (
     SELECT Book_ID, COUNT(*) AS [Count]
	 FROM Loans
	 GROUP BY Book_ID
)
SELECT Author, 
SUM([Count]) OVER(PARTITION BY Author ORDER BY Author) AS [Books]
FROM Books AS B INNER JOIN GroupsCount AS G ON B.Book_ID = G.Book_ID
ORDER BY [Books] DESC;
```
- **Rationale**: This query ranks authors based on the total number of their books that have been borrowed, identifying the most popular authors in the library.

---

### **10. Genre Preference by Age using Group By and Having**
```sql
CREATE FUNCTION dbo.fn_Age(@BirthOfDate DATE)
RETURNS INT
AS
BEGIN
     RETURN DATEDIFF(YEAR, @BirthOfDate, GETDATE());
END;

CREATE FUNCTION fn_CalculateAgeRange(@Age INT)
RETURNS VARCHAR(6)
AS
BEGIN
     RETURN (CASE WHEN @Age BETWEEN 0 AND 10 THEN '0-10'
                  WHEN @Age BETWEEN 11 AND 20 THEN '11-20'
			      WHEN @Age BETWEEN 21 AND 30 THEN '21-30'
			      WHEN @Age BETWEEN 31 AND 40 THEN '31-40'
			      WHEN @Age BETWEEN 41 AND 50 THEN '41-50'
			      WHEN @Age BETWEEN 51 AND 60 THEN '51-60'
			      WHEN @Age BETWEEN 61 AND 70 THEN '61-70'
			      WHEN @Age BETWEEN 71 AND 80 THEN '71-80'
			      WHEN @Age BETWEEN 81 AND 90 THEN '81-90'
			      WHEN @Age BETWEEN 91 AND 100 THEN '91-100'
			      ELSE 'Other' END);
END;


-- using Group By and Having
WITH GroupsOfAgesForBorrowers AS 
(
     SELECT dbo.fn_CalculateAgeRange(dbo.fn_Age([Date of Birth])) AS [Age Range], Genre, COUNT(Genre) AS [Count]
     FROM Borrowers AS P 
     INNER JOIN
     Loans AS L ON P.Borrower_ID = L.Borrower_ID
     INNER JOIN
     Books AS B ON L.Book_ID = B.Book_ID 
	 WHERE Genre <> '(no genres listed)'
	 GROUP BY dbo.fn_CalculateAgeRange(dbo.fn_Age([Date of Birth])), Genre
)
SELECT * FROM GroupsOfAgesForBorrowers
ORDER BY [Age Range], [Count] DESC;




-- Window Functions
WITH GroupsOfAgesForBorrowers AS 
(
     SELECT DISTINCT dbo.fn_CalculateAgeRange(dbo.fn_Age([Date of Birth])) AS [Age Range], Genre,
	 COUNT(Genre) OVER(PARTITION BY dbo.fn_CalculateAgeRange(dbo.fn_Age([Date of Birth])), Genre
	                   ORDER BY dbo.fn_CalculateAgeRange(dbo.fn_Age([Date of Birth]))) AS [Count]
	 FROM Borrowers AS P 
     INNER JOIN
     Loans AS L ON P.Borrower_ID = L.Borrower_ID
     INNER JOIN
     Books AS B ON L.Book_ID = B.Book_ID 
	 WHERE Genre <> '(no genres listed)'
)
SELECT * FROM GroupsOfAgesForBorrowers
ORDER BY [Age Range], [Count] DESC;
```
- **Rationale**: This function categorizes borrowers into predefined age groups based on their date of birth, allowing the library to segment its user base by age.

---

### **11. Borrowed Books Report Procedure**
```sql
CREATE OR ALTER PROCEDURE sp_BorrowedBooksReport(@StartDate DATE, @EndDate DATE)
AS
BEGIN
     SELECT B.Borrower_ID, CONCAT([First Name], ' ', [Last Name]) AS [Name], [Date Borrowed]
	 FROM Borrowers AS B INNER JOIN Loans AS L ON B.Borrower_ID = L.Borrower_ID
	 WHERE [Date Borrowed] BETWEEN @StartDate AND @EndDate
END;

EXEC sp_BorrowedBooksReport '2024-01-29', '2024-01-30';
```
- **Rationale**: This stored procedure generates a report of all books borrowed within a specified date range, including relevant borrower and loan details.

---

### **12. Trigger Implementation**
```sql
CREATE TABLE AuditLog (
      Audit_ID INT IDENTITY(1,1) PRIMARY KEY,
      Book_ID INT NOT NULL,
	  [Status Change] VARCHAR(9) NOT NULL,
	  [Change Date] DATE NOT NULL DEFAULT GETDATE()
);

CREATE OR ALTER TRIGGER [On Updating Books Status] ON Books
AFTER UPDATE 
AS
BEGIN
     IF EXISTS (SELECT * 
	            FROM inserted AS i 
				INNER JOIN 
				deleted AS d ON i.Book_ID = D.Book_ID 
				WHERE i.[Current Status] <> d.[Current Status])
	 BEGIN
	      INSERT INTO AuditLog (Book_ID, [Status Change])
          SELECT i.Book_ID, i.[Current Status]
          FROM inserted AS i
          INNER JOIN deleted AS d 
          ON i.Book_ID = d.Book_ID
          WHERE i.[Current Status] <> d.[Current Status];
	 END
END;
```
- **Rationale**: This trigger logs any changes in the status of books in the Books table, such as a change from "Available" to "Borrowed," allowing the library to track book status history.

---

### **14. SQL Stored Procedure with Temp Table**
```sql
CREATE OR ALTER PROCEDURE sp_OverdueBooks
AS
BEGIN
     CREATE TABLE #TempBorrowers (
	        Borrower_ID INT,
			Book_ID INT,
	        [First Name] VARCHAR(35) NOT NULL,
	        [Last Name] VARCHAR(35) NOT NULL,
			[Date Borrowed] DATE,
	        [Due Date] DATE,
			[Date Returned] DATE,
	 );

	 INSERT INTO #TempBorrowers (Borrower_ID, Book_ID, [First Name], [Last Name], [Date Borrowed], [Due Date], [Date Returned])
	 SELECT B.Borrower_ID, Book_ID, [First Name], [Last Name], 
	        [Date Borrowed], [Due Date], [Date Returned]
	 FROM Borrowers AS B INNER JOIN Loans AS L ON B.Borrower_ID = L.Borrower_ID
	 WHERE ([Date Returned] IS NULL AND GETDATE() > [Due Date]) 
	       OR 
		   ([Date Returned] IS NOT NULL AND [Date Returned] > [Due Date]);

	 SELECT T.*, Title
	 FROM #TempBorrowers AS T INNER JOIN Books AS B ON T.Book_ID = B.Book_ID
	 ORDER BY Borrower_ID;

	 DROP TABLE #TempBorrowers;
END;

EXEC sp_OverdueBooks;
```
- **Rationale**: This stored procedure retrieves borrowers who have overdue books and temporarily stores them in a temp table. It then joins this data with other information to generate a detailed overdue report.

---

### **15. Weekly peak days**
```sql
WITH [Records Number] AS 
(
     SELECT COUNT(*) AS [Records] FROM Loans
)
SELECT TOP 3 [Day], 
CONCAT(
CONVERT(
DECIMAL(10, 2), 
ROUND(
CAST([Percentage] AS DECIMAL(10, 2)) / 
COALESCE(
NULLIF(
CAST([Records] AS DECIMAL(10, 2)),
0), 
1) * 100.00, 
2)), '%') 
AS [Percentage]
FROM (
SELECT DATENAME(WEEKDAY, [Date Borrowed]) AS [Day], COUNT(*) AS [Percentage]
FROM Loans
GROUP BY DATENAME(WEEKDAY, [Date Borrowed])) AS D, [Records Number]
ORDER BY [Percentage] DESC;
```
- **Rationale**: This query returns the top three days of the week when the most books were borrowed, along with the percentage of total loans for each day, offering insights into peak borrowing days.
