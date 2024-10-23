DECLARE @ID INT = 7;

SELECT B.*, [Date Returned]
FROM Loans AS L INNER JOIN Books AS B ON L.Book_ID = B.Book_ID
WHERE L.Book_ID = @ID;




