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
