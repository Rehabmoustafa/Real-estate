----------- 1 / Add Employee -----------
CREATE OR ALTER PROCEDURE AddEmployee
    @Name VARCHAR(255),
    @Date_Of_Birth DATE,
    @Age INT,
    @Gender VARCHAR(10),
    @Hire_DATE DATE,
    @Email VARCHAR(255),
    @Department_ID INT,
	@PhoneNumber INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @NewEmployeeID INT

    INSERT INTO Employee (Name,  Date_Of_Birth, Age, Gender, Hire_DATE, Email, Department_ID)
    VALUES (@Name, @Date_Of_Birth, @Age, @Gender, @Hire_DATE, @Email, @Department_ID)

    SET @NewEmployeeID = SCOPE_IDENTITY()

    IF @PhoneNumber IS NOT NULL
    BEGIN
        INSERT INTO Employee_Phone (Employee_ID, Phone)
        VALUES (@NewEmployeeID, @PhoneNumber)
    END

    SELECT @NewEmployeeID AS EmployeeID
END
GO
/*EXEC AddEmployee
    @Name = 'Ahmed Saeed',
    @Date_Of_Birth = '1990-05-15',
    @Age = 34,
    @Gender = 'Male',
    @Hire_DATE = '2024-03-01',
    @Email = 'ahmed.saeed@example.com',
    @Department_ID = 2,
    @PhoneNumber = 0123456789
GO
*/


----------- 2 / Update Employee ----------- 
CREATE OR ALTER PROCEDURE UpdateEmployee
    @Employee_ID INT,
    @Name VARCHAR(255) = NULL,
    @Date_Of_Birth DATE = NULL,
    @Age INT = NULL,
    @Gender VARCHAR(10) = NULL,
    @Hire_DATE DATE = NULL,
    @Email VARCHAR(255) = NULL,
    @Department_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    UPDATE Employee
    SET
        Name = ISNULL(@Name, Name),
        Date_Of_Birth = ISNULL(@Date_Of_Birth, Date_Of_Birth),
        Age = ISNULL(@Age, Age),
        Gender = ISNULL(@Gender, Gender),
        Hire_DATE = ISNULL(@Hire_DATE, Hire_DATE),
        Email = ISNULL(@Email, Email),
        Department_ID = ISNULL(@Department_ID, Department_ID)
    WHERE ID = @Employee_ID
END
GO

----------- 3 /  Delete Employee ----------- 
CREATE OR ALTER PROCEDURE DeleteEmployee
    @Employee_ID INT
AS
BEGIN
    SET NOCOUNT ON
    DELETE FROM Employee_Phone WHERE Employee_ID = @Employee_ID
    DELETE FROM Employee WHERE ID = @Employee_ID
END
GO


----------- 4 /  Get Employee By ID -----------  
CREATE OR ALTER PROCEDURE GetEmployeeByID
    @Employee_ID INT
AS
BEGIN
    SET NOCOUNT ON
    SELECT 
		E.*, 
		D.Name AS Department_Name, 
		EP.Phone
    FROM 
		Employee E
    INNER JOIN 
		Department D ON E.Department_ID = D.ID
    LEFT JOIN 
		Employee_Phone EP ON E.ID = EP.Employee_ID
    WHERE 
		E.ID = @Employee_ID
END
GO

----------- 5 / Add Property -----------  
CREATE OR ALTER PROCEDURE AddProperty
    @Type VARCHAR(50),
    @Price DECIMAL(18, 2),
    @Room INT,
    @Area INT,
	@Bathroom INT,
    @Status VARCHAR(50),
    @Fureniture VARCHAR(50),
    @Year_Built DATE,
    @Payment_Method VARCHAR(50),
    @Owner_ID INT
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO Property (Type, Price, Room, Area, Bathroom,  Status, Fureniture, Year_Built, Payment_Method, Owner_ID)
    VALUES (@Type, @Price, @Room, @Area, @Bathroom, @Status, @Fureniture, @Year_Built, @Payment_Method, @Owner_ID)
    SELECT SCOPE_IDENTITY() AS PropertyID
END
GO

----------- 6 / Update Property -----------   
CREATE OR ALTER PROCEDURE UpdateProperty
    @Property_ID INT,
    @Type VARCHAR(50) = NULL,
    @Price DECIMAL(18, 2) = NULL,
    @Room INT = NULL,
    @Area INT = NULL,
	@Bathroom INT = NULL,
    @Status VARCHAR(50) = NULL,
    @Fureniture VARCHAR(50) = NULL,
    @Year_Built DATE = NULL,
    @Payment_Method VARCHAR(50) = NULL,
    @Owner_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    UPDATE Property
    SET
        Type = ISNULL(@Type, Type),
        Price = ISNULL(@Price, Price),
        Room = ISNULL(@Room, Room),
        Bathroom = ISNULL(@Bathroom, Bathroom),
        Status = ISNULL(@Status, Status),
        Fureniture = ISNULL(@Fureniture, Fureniture),
        Year_Built = ISNULL(@Year_Built, Year_Built),
        Payment_Method = ISNULL(@Payment_Method, Payment_Method),
        Owner_ID = ISNULL(@Owner_ID, Owner_ID)
    WHERE ID = @Property_ID
END
GO

----------- 7 / Delete Property -----------   
CREATE OR ALTER PROCEDURE DeleteProperty
    @Property_ID INT
AS
BEGIN
    SET NOCOUNT ON
    DELETE FROM Property WHERE ID = @Property_ID
END
GO

----------- 8 / Get Property By ID ----------هنا استخدم ال view من اللى عاملينها-   
CREATE OR ALTER PROCEDURE GetPropertyByID
    @Property_ID INT
AS
BEGIN
    SET NOCOUNT ON
    SELECT * FROM Property_Full_Details WHERE Property_ID = @Property_ID
END
GO

----------- 9 / Add Client -----------    
CREATE OR ALTER PROCEDURE AddClient
    @Name VARCHAR(255),
    @Type VARCHAR(50),
    @PhoneNumber VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @NewClientID INT
    INSERT INTO Client (Name, Type)
    VALUES (@Name, @Type)
    SET @NewClientID = SCOPE_IDENTITY()

    IF @PhoneNumber IS NOT NULL
    BEGIN
        INSERT INTO Client_Phone (Client_ID, Phone)
        VALUES (@NewClientID, @PhoneNumber)
    END
    SELECT @NewClientID AS ClientID
END
GO

----------- 10 /  Update Client -----------    
CREATE OR ALTER PROCEDURE UpdateClient
    @Client_ID INT,
    @Name VARCHAR(255) = NULL,
    @Type VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON
    UPDATE Client
    SET
        Name = ISNULL(@Name, Name),
        Type = ISNULL(@Type, Type)
    WHERE ID = @Client_ID
END
GO

----------- 11 / Add Owner -----------     
CREATE OR ALTER PROCEDURE AddOwner
    @Name VARCHAR(255),
    @Type VARCHAR(50),
    @Address VARCHAR(255),
    @Email VARCHAR(255),
    @PhoneNumber VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @NewOwnerID INT
    INSERT INTO Owner (Name, Type, Address, Email)
    VALUES (@Name, @Type, @Address, @Email)
    SET @NewOwnerID = SCOPE_IDENTITY()

    IF @PhoneNumber IS NOT NULL
    BEGIN
        INSERT INTO Owner_Phone (Owner_ID, Phone)
        VALUES (@NewOwnerID, @PhoneNumber)
    END
    SELECT @NewOwnerID AS OwnerID
END
GO

----------- 12 / Add Broker -----------     
CREATE OR ALTER PROCEDURE AddBroker
    @Name VARCHAR(255),
    @License_Number VARCHAR(50),
    @Agency_Name VARCHAR(255),
    @Email VARCHAR(255),
    @PhoneNumber VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @NewBrokerID INT
    INSERT INTO Broker (Name, License_Number, Agency_Name, Email)
    VALUES (@Name, @License_Number, @Agency_Name, @Email)
    SET @NewBrokerID = SCOPE_IDENTITY()

    IF @PhoneNumber IS NOT NULL
    BEGIN
        INSERT INTO Broker_Phone (Broker_ID, Phone)
        VALUES (@NewBrokerID, @PhoneNumber)
    END
    SELECT @NewBrokerID AS BrokerID
END
GO

----------- 13 /  Schedule Appointment -----------     
CREATE OR ALTER PROCEDURE ScheduleAppointment
    @Date DATE,
    @Status VARCHAR(50),
    @Property_ID INT,
    @Employee_ID INT,
    @Client_ID INT,
    @Broker_ID INT = NULL 
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @NewAppointmentID INT

    INSERT INTO Appointment (Date, Status, Property_ID, Employee_ID, Client_ID)
    VALUES (@Date, @Status, @Property_ID, @Employee_ID, @Client_ID)

    SET @NewAppointmentID = SCOPE_IDENTITY()

    IF @Broker_ID IS NOT NULL
    BEGIN
        INSERT INTO Appointment_Broker (Appointment_ID, Broker_ID)
        VALUES (@NewAppointmentID, @Broker_ID)
    END
    SELECT @NewAppointmentID AS AppointmentID
END
GO

----------- 14 /  Update Appointment Status -----------     
CREATE OR ALTER PROCEDURE UpdateAppointmentStatus
    @Appointment_ID INT,
    @NewStatus VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON
    UPDATE Appointment
    SET Status = @NewStatus
    WHERE ID = @Appointment_ID
END
GO

----------- 15 /  Create Listing -----------     
CREATE OR ALTER PROCEDURE CreateListing
    @Property_ID INT,
    @Employee_ID INT,
    @Date DATE,
	@Broker_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @NewListingID INT

    INSERT INTO Listing (Property_ID, Employee_ID, Date)
    VALUES (@Property_ID, @Employee_ID, @Date)

    SET @NewListingID = SCOPE_IDENTITY()

    IF @Broker_ID IS NOT NULL
    BEGIN
        INSERT INTO Listing_Broker (Listing_ID, Broker_ID)
        VALUES (@NewListingID, @Broker_ID)
    END
    SELECT @NewListingID AS ListingID
END
GO
----------- 16 /  Record Payment -----------     
CREATE OR ALTER PROCEDURE RecordPayment
    @Date DATE,
    @Type VARCHAR(50),
    @Movement_Type VARCHAR(50),
    @Related_Type VARCHAR(50),
    @Client_ID INT,
    @Broker_ID INT,
    @Employee_ID INT,
    @Property_ID INT,
    @Owner_ID INT,
	@Profit INT,
    @Employee_Commission DECIMAL(18, 2),
    @Broker_Commission DECIMAL(18, 2),
    @Amount_To_Owner DECIMAL(18, 2)
AS
BEGIN
    SET NOCOUNT ON
    INSERT INTO Payment (Date, Type, Movement_Type, Related_Type, Client_ID, Broker_ID, Employee_ID, Property_ID, Owner_ID, Employee_Commission, Broker_Commission, Amount_To_Owner)
    VALUES (@Date, @Type, @Movement_Type, @Related_Type, @Client_ID, @Broker_ID, @Employee_ID, @Property_ID, @Owner_ID, @Employee_Commission, @Broker_Commission, @Amount_To_Owner)
    SELECT SCOPE_IDENTITY() AS PaymentID
END
GO

----------- 17 /  Get Broker Commissions -----------     
CREATE OR ALTER PROCEDURE GetBrokerCommissions
    @Broker_ID INT
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        P.ID AS Payment_ID,
        P.Date,
        P.Broker_ID,
        P.Broker_Commission
	FROM
        Payment P
    LEFT JOIN 
		Client C ON P.Client_ID = C.ID
    WHERE
        P.Broker_ID = @Broker_ID
        AND P.Broker_Commission IS NOT NULL
END
GO


----------- 18 / Get Employee Appointments By Date -----------     
CREATE OR ALTER PROCEDURE GetEmployeeAppointmentsByDate
    @Employee_ID INT,
    @AppointmentDate DATE
AS
BEGIN
    SET NOCOUNT ON
    SELECT 
		A.ID AS AppointmentID, 
		A.Date, 
		A.Status, 
		C.Name AS ClientName
    FROM 
		Appointment A
    INNER JOIN 
		Property P ON A.Property_ID = P.ID
    INNER JOIN 
		Client C ON A.Client_ID = C.ID
    WHERE 
		A.Employee_ID = @Employee_ID 
		AND A.Date = @AppointmentDate
END
GO

----------- 19 / Search Properties -----------     
CREATE OR ALTER PROCEDURE SearchProperties
    @PropertyType VARCHAR(50) = NULL,
    @MinPrice DECIMAL(18, 2) = NULL,
    @MaxPrice DECIMAL(18, 2) = NULL,
    @Room INT = NULL,
    @Bathroom INT = NULL,
    @Status VARCHAR(50) = NULL,
    @City VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON
    SELECT 
		P.ID, 
		P.Type, 
		P.Price, 
		P.Room, 
		P.Bathroom,  
		P.Status, 
		L.City, 
		O.Name AS OwnerName
    FROM 
		Property P
    INNER JOIN 
		Location L ON P.ID = L.Property_ID
    INNER JOIN 
		Owner O ON P.Owner_ID = O.ID
    WHERE
        (@PropertyType IS NULL OR P.Type = @PropertyType)
        AND (@MinPrice IS NULL OR P.Price >= @MinPrice)
        AND (@MaxPrice IS NULL OR P.Price <= @MaxPrice)
        AND (@Room IS NULL OR P.Room >= @Room)
        AND (@Bathroom IS NULL OR P.Bathroom >= @Bathroom)
        AND (@Status IS NULL OR P.Status = @Status)
        AND (@City IS NULL OR L.City = @City)
END
GO

----------- 20 /  Assign Broker To Appointment -----------     
CREATE OR ALTER PROCEDURE AssignBrokerToAppointment
    @Appointment_ID INT,
    @Broker_ID INT
AS
BEGIN
    SET NOCOUNT ON
    -- Check if assignment already exists to prevent duplicates
    IF NOT EXISTS (SELECT 1 FROM Appointment_Broker WHERE Appointment_ID = @Appointment_ID AND Broker_ID = @Broker_ID)
    BEGIN
        INSERT INTO Appointment_Broker (Appointment_ID, Broker_ID)
        VALUES (@Appointment_ID, @Broker_ID)
    END
    ELSE
    BEGIN
        PRINT 'Broker already assigned to this appointment.'
    END
END
GO


----------- 21 / Update Property Owner -----------     
CREATE OR ALTER PROCEDURE UpdatePropertyOwner
    @Property_ID INT,
    @NewOwner_ID INT
AS
BEGIN
    SET NOCOUNT ON
    UPDATE Property
    SET Owner_ID = @NewOwner_ID
    WHERE ID = @Property_ID
END
GO

----------- 22 / Get Payments Summary -----------      
CREATE OR ALTER PROCEDURE GetPaymentsSummary
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @PaymentType VARCHAR(50) = NULL,
    @Client_ID INT = NULL,
    @Property_ID INT = NULL,
    @Broker_ID INT = NULL,
    @Employee_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        Py.ID AS PaymentID,
        Py.Date AS PaymentDate,
        Py.Type AS PaymentType,
        Py.Movement_Type,
        Py.Related_Type,
        Py.Employee_Commission,
        Py.Broker_Commission,
        Py.Amount_To_Owner,
        C.Name AS ClientName,
        Br.Name AS BrokerName,
        Em.Name AS EmployeeName,
        O.Name AS OwnerName
    FROM
        Payment Py
    LEFT JOIN 
		Client C ON Py.Client_ID = C.ID
    LEFT JOIN 
		Broker Br ON Py.Broker_ID = Br.ID
    LEFT JOIN 
		Employee Em ON Py.Employee_ID = Em.ID
    LEFT JOIN 
		Property Pr ON Py.Property_ID = Pr.ID
    LEFT JOIN 
		Owner O ON Py.Owner_ID = O.ID
    WHERE
        (@StartDate IS NULL OR Py.Date >= @StartDate)
        AND (@EndDate IS NULL OR Py.Date <= @EndDate)
        AND (@PaymentType IS NULL OR Py.Type = @PaymentType)
        AND (@Client_ID IS NULL OR Py.Client_ID = @Client_ID)
        AND (@Property_ID IS NULL OR Py.Property_ID = @Property_ID)
        AND (@Broker_ID IS NULL OR Py.Broker_ID = @Broker_ID)
        AND (@Employee_ID IS NULL OR Py.Employee_ID = @Employee_ID)
END
GO

EXEC GetPaymentsSummary @StartDate = '2025-07-01', @EndDate = '2025-07-31';
EXEC GetPaymentsSummary @PaymentType = 'For Sale', @Client_ID = 101;
EXEC GetPaymentsSummary @Property_ID = 50;
EXEC GetPaymentsSummary;

d
