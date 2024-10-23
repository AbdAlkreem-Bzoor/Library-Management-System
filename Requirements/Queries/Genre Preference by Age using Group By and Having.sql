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