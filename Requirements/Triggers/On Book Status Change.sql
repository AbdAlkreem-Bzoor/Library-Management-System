CREATE TABLE AuditLog (
      Audit_ID INT IDENTITY(1,1) PRIMARY KEY,
      Book_ID INT NOT NULL,
	  [Status Change] VARCHAR(9) NOT NULL,
	  [Change Date] DATE NOT NULL DEFAULT GETDATE()
);

CREATE OR ALTER TRIGGER [On Updating Books Status] ON Books
AFTER UPDATE 
AS
BEGIN
     IF EXISTS (SELECT * 
	            FROM inserted AS i 
				INNER JOIN 
				deleted AS d ON i.Book_ID = D.Book_ID 
				WHERE i.[Current Status] <> d.[Current Status])
	 BEGIN
	      INSERT INTO AuditLog (Book_ID, [Status Change])
          SELECT i.Book_ID, i.[Current Status]
          FROM inserted AS i
          INNER JOIN deleted AS d 
          ON i.Book_ID = d.Book_ID
          WHERE i.[Current Status] <> d.[Current Status];
	 END
END;




