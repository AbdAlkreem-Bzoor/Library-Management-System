CREATE OR ALTER PROCEDURE sp_BorrowedBooksReport(@StartDate DATE, @EndDate DATE)
AS
BEGIN
     SELECT B.Borrower_ID, CONCAT([First Name], ' ', [Last Name]) AS [Name], [Date Borrowed]
	 FROM Borrowers AS B INNER JOIN Loans AS L ON B.Borrower_ID = L.Borrower_ID
	 WHERE [Date Borrowed] BETWEEN @StartDate AND @EndDate
END;

EXEC sp_BorrowedBooksReport '2024-01-29', '2024-01-30';