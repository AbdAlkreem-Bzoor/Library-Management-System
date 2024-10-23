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
