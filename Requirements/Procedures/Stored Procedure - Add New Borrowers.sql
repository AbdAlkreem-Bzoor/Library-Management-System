CREATE OR ALTER PROCEDURE sp_AddNewBorrower (
    @FirstName VARCHAR(35), 
    @LastName VARCHAR(35), 
    @Email VARCHAR(270), 
    @DateOfBirth DATE, 
    @MembershipDate DATE,
    @LastInsertedBorrowerID INT OUTPUT
)
AS
BEGIN
    IF EXISTS(SELECT Email FROM Borrowers WHERE Email = @Email)
    BEGIN
        RAISERROR('Email already exists!', 16, 1);
    END
	ELSE
	BEGIN
    INSERT INTO Borrowers VALUES (@FirstName, @LastName, @Email, @DateOfBirth, @MembershipDate);
    SET @LastInsertedBorrowerID = CONVERT(INT, SCOPE_IDENTITY());
	END
END;


DECLARE @ID INT = 1;
EXEC sp_AddNewBorrower 'Abdalmreem', 'Bzoor', 'bzoor147@gmail.com', '2003-07-24', '2024-10-22', @ID;

SELECT * FROM Borrowers;
DELETE FROM Borrowers WHERE Borrower_ID = @ID;
