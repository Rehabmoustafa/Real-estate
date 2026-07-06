USE [Real_Estate]

-----------------CREATION-----------------

CREATE TABLE Property(
	ID INT PRIMARY KEY,
	Type VARCHAR(25),
	Price INT ,
	Room INT,
	Area DECIMAL(18,2),
	Finished CHAR(10),
	Bathroom INT,
    Status VARCHAR(25),
	Fureniture CHAR(10),
	Year_Built DATE,
	Payment_Method,
	Owner_ID INT
)

GO

CREATE TABLE Location (
	ID INT PRIMARY KEY,
	Country VARCHAR(25),
	State VARCHAR(25),
	City VARCHAR(25),
	Street VARCHAR(50),
	Building CHAR(20),
	Unit INT,
	Longitude FLOAT,
	Latitude FLOAT,
	Zipcode CHAR(10),
	Property_ID INT
)

GO

CREATE TABLE Payment (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Date DATETIME,
    Type NVARCHAR(20),
    Movement_Type NVARCHAR(10),
    Related_Type NVARCHAR(10),
    Client_ID INT NULL,
    Owner_ID INT NULL,
    Broker_ID INT NULL,
    Employee_ID INT NULL,
    Property_ID INT,
	Profit INT NULL,
	Employee_Commission INT NULL,
	Broker_Commission INT NULL,
	Amount_To_Owner INT NULL
)

GO

CREATE TABLE Owner(
	ID INT PRIMARY KEY,
	Name VARCHAR(50),
	Type CHAR(20),
	Address VARCHAR(100),
	Email VARCHAR(100)
)


GO
CREATE TABLE Owner_Phone(
	Owner_ID INT,
	Phone CHAR(50),
	PRIMARY KEY(Owner_ID,Phone)

	)
GO

CREATE TABLE Department(
	ID INT PRIMARY KEY,
	Name CHAR(25),
	Manager_ID INT
)

GO

CREATE TABLE Employee (
	ID INT PRIMARY KEY,
	Name CHAR(25),
	Date_Of_Birth DATE,
	Address VARCHAR(100),
	Age INT,
	Salary INT, 
    Gender CHAR(1),
	Hire_DATE DATE,
	Email VARCHAR(100),
	Department_ID INT
)

GO

CREATE TABLE Employee_Phone (
	Employee_ID INT,
	Phone varchar(50)
	PRIMARY KEY (Employee_ID,Phone)
)

GO 

CREATE TABLE Appointment_Broker(
	Appointment_ID INT PRIMARY KEY,
	Broker_ID INT
)

GO


CREATE TABLE listing(
	ID INT PRIMARY KEY,
	Date DATE ,
	Status CHAR (20),
	Property_ID INT ,
	Employee_ID INT
)

GO

CREATE TABLE Appointment (
	ID INT PRIMARY KEY ,
	Date DATE ,
	Status CHAR(20),
	Property_ID INT,
	Employee_ID INT,
	Client_ID INT 
)


GO 

CREATE TABLE Broker(
	ID INT PRIMARY KEY,
	Name VARCHAR(50),
	License_Number INT ,
	Agency_Name VARCHAR(50),
	Email VARCHAR(100)
)

GO

CREATE TABLE Broker_Phone(
	Broker_ID INT,
	Phone CHAR(50),
	PRIMARY KEY (Broker_ID ,Phone)
)

GO

CREATE TABLE Listing_Broker(
	Listing_ID INT ,
	Broker_ID INT ,
	PRIMARY KEY (Listing_ID,Broker_ID)
)

GO

CREATE TABLE Client(
	ID INT PRIMARY KEY ,
	Name VARCHAR(50) ,
	Type VARCHAR(20) ,
	Address VARCHAR(100),
	Email VARCHAR(100)
)

GO

CREATE TABLE Client_Phone (
	Client_ID INT,
	Phone VARCHAR(50),
	PRIMARY KEY (Client_ID,Phone)
)
GO
--------Creation of Trigger----------
CREATE TABLE Employee_Salary_Log
(
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    OldSalary DECIMAL(18,2),
    NewSalary DECIMAL(18,2),
    UpdateDate DATETIME DEFAULT GETDATE()
)

Go


CREATE TABLE Owner_Property_Summary 
(
    Owner_ID INT PRIMARY KEY,
    PropertyCount INT NOT NULL
)
Go

CREATE TABLE Property_Backup
(
    ID INT,
    Type VARCHAR(100),
    Area FLOAT,
    Status VARCHAR(50),
    Price DECIMAL(18,2),
    Backup_Date DATETIME
)
Go

Create Table Broker_Deleted_Log
(
ID int Primary Key,
DeletedAt date
)
Go   



-----------------ALTER-----------------
--Property
ALTER TABLE dbo.Property
ADD FOREIGN KEY (Owner_ID) REFERENCES dbo.Owner(ID)

--Location
ALTER TABLE dbo.Location
ADD FOREIGN KEY (Property_ID) REFERENCES dbo.Property(ID)

--Payment
ALTER TABLE dbo.Payment
ADD FOREIGN KEY (Client_ID) REFERENCES dbo.Client(ID)

ALTER TABLE dbo.Payment
ADD FOREIGN KEY (Owner_ID) REFERENCES dbo.Owner(ID)

ALTER TABLE dbo.Payment
ADD FOREIGN KEY (Broker_ID) REFERENCES dbo.Broker(ID)

ALTER TABLE dbo.Payment
ADD FOREIGN KEY (Employee_ID) REFERENCES dbo.Employee(ID)

ALTER TABLE dbo.Payment
ADD FOREIGN KEY (Property_ID) REFERENCES dbo.Property(ID)


--Owner
ALTER TABLE dbo.Owner_Phone
ADD FOREIGN KEY (Owner_ID) REFERENCES dbo.Owner(ID)

--Department
ALTER TABLE dbo.Department
ADD FOREIGN KEY (Manager_ID) REFERENCES dbo.Employee(ID)

--Employee
ALTER TABLE dbo.Employee 
ADD FOREIGN KEY (Department_ID) REFERENCES dbo.Department(ID)

ALTER TABLE dbo.Employee_Phone
ADD FOREIGN KEY (Employee_ID) REFERENCES dbo.Employee(ID)

--Appointment
ALTER TABLE dbo.Appointment
ADD FOREIGN KEY (Employee_ID) REFERENCES dbo.Employee(ID)

ALTER TABLE dbo.Appointment
ADD FOREIGN KEY (Property_ID) REFERENCES dbo.Property(ID)

ALTER TABLE dbo.Appointment
ADD FOREIGN KEY (Client_ID) REFERENCES dbo.Client(ID)


--Listing
ALTER TABLE dbo.listing
ADD FOREIGN KEY (Property_ID) REFERENCES dbo.Property(ID)

ALTER TABLE dbo.listing
ADD FOREIGN KEY (Employee_ID) REFERENCES dbo.Employee(ID)


--Appointment_Broker
ALTER TABLE dbo.Appointment_Broker
ADD FOREIGN KEY (Appointment_ID) REFERENCES dbo.Appointment(ID)

ALTER TABLE dbo.Appointment_Broker
ADD FOREIGN KEY (Broker_ID) REFERENCES dbo.Broker(ID)

--Listing_Broker
ALTER TABLE dbo.Listing_Broker
ADD FOREIGN KEY (Broker_ID) REFERENCES dbo.Broker(ID)

ALTER TABLE dbo.Listing_Broker
ADD FOREIGN KEY (Listing_ID) REFERENCES dbo.listing(ID)


--Broker_Phone
ALTER TABLE dbo.Broker_Phone
ADD FOREIGN KEY (Broker_ID) REFERENCES dbo.Broker(ID)

--Client_Phone
ALTER TABLE dbo.Client_Phone
ADD FOREIGN KEY (Client_ID) REFERENCES dbo.Client(ID)




