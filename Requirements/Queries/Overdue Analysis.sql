SELECT B.Borrower_ID, CONCAT([First Name], ' ', [Last Name]) AS [Name],
Book_ID, [Date Borrowed], [Due Date], [Date Returned]
FROM Loans AS L INNER JOIN Borrowers AS B ON L.Borrower_ID = B.Borrower_ID
WHERE DATEADD(DAY, -30, ISNULL([Date Returned], GETDATE())) > [Due Date]
ORDER BY B.Borrower_ID;
