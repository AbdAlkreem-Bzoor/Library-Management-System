-- using CTE's & Window Functions & JOIN
WITH GroupsCount AS (
     SELECT Borrower_ID, COUNT(*) AS [Borrowing Frequency]
	 FROM Loans
	 GROUP BY Borrower_ID
)
SELECT B.Borrower_ID, [First Name], [Last Name], [Borrowing Frequency],
DENSE_RANK() OVER(ORDER BY [Borrowing Frequency] DESC) AS [Rank]
FROM Borrowers AS B INNER JOIN GroupsCount AS G ON B.Borrower_ID = G.Borrower_ID;




