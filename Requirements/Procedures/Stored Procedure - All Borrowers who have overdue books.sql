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