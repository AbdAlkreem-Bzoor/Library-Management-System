CREATE FUNCTION fn_CalculateOverdueFees(@Loan_ID INT)
RETURNS INT
AS
BEGIN
     DECLARE @DueDate DATE;
	 SELECT @DueDate = [Due Date] FROM Loans WHERE Loan_ID = @Loan_ID;

	 DECLARE @ReturnDate DATE;
	 SELECT @ReturnDate = [Date Returned] FROM Loans WHERE Loan_ID = @Loan_ID;

	 DECLARE @Difference INT;

	 IF @ReturnDate IS NULL
	 BEGIN
        SET @Difference = DATEDIFF(DAY, @DueDate, GETDATE());
	 END
     ELSE
	 BEGIN
        SET @Difference = DATEDIFF(DAY, @DueDate, @ReturnDate);
	 END

	 IF @Difference < 0
     BEGIN
        RETURN 0;
     END

	 DECLARE @MinValue INT = CASE WHEN @Difference < 30 THEN @Difference ELSE 30 END;
	 DECLARE @Result INT = @MinValue;

	 SET @Difference = @Difference - @MinValue;
	 SET @Result = @Result + @Difference * 2;

	 RETURN @Result;
END;

SELECT CONCAT('$', dbo.fn_CalculateOverdueFees(Loan_ID)) AS [Overdue Fees]
FROM Loans;