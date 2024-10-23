CREATE DATABASE [Library Management System];

USE [Library Management System];


CREATE TABLE Borrowers (
     Borrower_ID INT,
	 [First Name] VARCHAR(35) NOT NULL,
	 [Last Name] VARCHAR(35) NOT NULL,
	 Email VARCHAR(270) NOT NULL UNIQUE,
	 [Date of Birth] DATE,
	 [Membership Date] DATE,
	 PRIMARY KEY (Borrower_ID)
);

CREATE TABLE Books (
     Book_ID INT,
	 Title VARCHAR(300),
	 Author VARCHAR(255),
	 ISBN VARCHAR(13),
	 [Published Date] DATE,
	 Genre VARCHAR(100),
	 [Shelf Location] VARCHAR(15),
	 [Current Status] VARCHAR(9) CHECK([Current Status] IN ('Available', 'Borrowed')),
	 PRIMARY KEY (Book_ID)
);

CREATE TABLE Loans (
     Loan_ID INT,
	 Borrower_ID INT,
	 Book_ID INT,
	 [Date Borrowed] DATE,
	 [Due Date] DATE,
	 [Date Returned] DATE,
	 PRIMARY KEY (Loan_ID),
	 FOREIGN KEY (Borrower_ID) REFERENCES Borrowers(Borrower_ID),
	 FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);
