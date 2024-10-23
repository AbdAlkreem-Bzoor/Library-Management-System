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


