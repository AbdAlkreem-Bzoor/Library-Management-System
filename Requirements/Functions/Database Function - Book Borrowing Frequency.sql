CREATE FUNCTION fn_BookBorrowingFrequency(@Book_ID INT)
RETURNS INT
BEGIN
     DECLARE @Result INT = 0;
     SELECT @Result = COUNT(*) FROM Loans WHERE Book_ID = @Book_ID;
	 RETURN @Result;
END;

SELECT * FROM Loans ORDER BY Book_ID;
SELECT dbo.fn_BookBorrowingFrequency(13);
