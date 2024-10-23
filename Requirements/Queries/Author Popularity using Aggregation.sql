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
