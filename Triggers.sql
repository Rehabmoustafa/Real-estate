
-- 1 /  If an employee's salary is updated, the new salary is recorded --
CREATE OR ALTER TRIGGER  trg_Employee_Salary_Update
ON Employee
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Salary)
    BEGIN
        INSERT INTO Employee_Salary_Log (EmployeeID, OldSalary, NewSalary, UpdateDate)
        SELECT 
            i.ID, 
			d.Salary, 
			i.Salary, 
			GETDATE()
        FROM inserted i
        INNER JOIN 
		deleted d ON i.ID = d.ID
    END
END
Go  


-- 2 /  This prevents you from deleting a client if they still have a scheduled appointment --
CREATE OR ALTER TRIGGER trg_Prevent_Client_Delete
ON Client
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Appointment WHERE Client_ID IN (SELECT ID FROM deleted)
    )
    BEGIN
        RAISERROR ('Cannot delete client with existing appointments', 16, 1)
        RETURN
    END
    DELETE FROM Client WHERE ID IN (SELECT ID FROM deleted)
END
Go

-- 3 / This prevents the commission from being negative for the broker --
CREATE OR ALTER TRIGGER trg_Broker_Negative_Commission
ON Payment
Instead of INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Broker_Commission < 0)
    BEGIN
        RAISERROR ('Commission cannot be negative.', 16, 1)
        ROLLBACK
    END
END
Go

-- 4 / This prevents the commission from being negative for the employee --
CREATE OR ALTER TRIGGER trg_Broker_Negative_Commission
ON Payment
Instead of INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Employee_Commission < 0)
    BEGIN
        RAISERROR ('Commission cannot be negative.', 16, 1)
        ROLLBACK
    END
END
Go

-- 5 / If 30 days have passed since the listing, it will be marked as expired --
CREATE OR ALTER TRIGGER trg_Update_Listing_Status
ON Listing
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Listing
    SET Status = 'Expired'
    WHERE DATEDIFF(DAY, Date, GETDATE()) > 30 AND Status != 'Expired'
END
Go

-- 6 / Prevents adding any property that doesn't have an Owner_ID --
CREATE OR ALTER TRIGGER trg_Block_Property_Without_Owner
ON Property
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Owner_ID IS NULL)
    BEGIN
        RAISERROR ('Cannot insert property without Owner_ID', 16, 1)
        RETURN
    END
    INSERT INTO Property
    SELECT * FROM inserted
END
Go

-- 7 / If an appointment is added without a status, the default will be set to Pending --
CREATE OR ALTER TRIGGER trg_Appointment_Default_Status
ON Appointment
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Appointment (ID, Date, Status, Property_ID, Employee_ID, Client_ID)
    SELECT ID, Date, ISNULL(Status, 'Pending'), Property_ID, Employee_ID, Client_ID
    FROM inserted
END

Go


-- 8 / If a broker is deleted, they are saved in another table along with the deletion date --
CREATE OR ALTER TRIGGER trg_Log_Broker_Delete
ON Broker
AFTER DELETE
AS
BEGIN
    INSERT INTO Broker_Deleted_Log (ID, DeletedAt)
    SELECT ID, GETDATE()
    FROM deleted
END
Go

-- 9 / If a payment is made, the status of the related property is changed to Sold --
CREATE OR ALTER TRIGGER trg_Update_Property_Status_On_Payment
ON Payment
AFTER INSERT
AS
BEGIN
    UPDATE Property
    SET Status = 'Sold'
    WHERE ID IN (SELECT Property_ID FROM inserted)
END
Go

-- 10 / When a property is added or deleted, another table is updated to reflect each owner and their associated properties --
CREATE OR Alter TRIGGER trg_Count_Owner_Properties
ON Property
AFTER INSERT, DELETE
AS
BEGIN    
    MERGE Owner_Property_Summary AS target
    USING (
        SELECT Owner_ID, COUNT(*) AS PropertyCount
        FROM Property
        GROUP BY Owner_ID
    ) AS source (Owner_ID, PropertyCount)
    ON target.Owner_ID = source.Owner_ID
    WHEN MATCHED THEN
        UPDATE SET target.PropertyCount = source.PropertyCount
    WHEN NOT MATCHED THEN
		INSERT  (Owner_ID, PropertyCount) VALUES (source.Owner_ID, source.PropertyCount);
END
Go  

-- 11 / Prevents booking an appointment on Fridays --
CREATE OR ALTER TRIGGER trg_No_Friday_Appointment
ON Appointment
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM INSERTED
        WHERE DATENAME(WEEKDAY, Date) = 'Friday'
    )
    BEGIN
        RAISERROR('Appointments cannot be scheduled on Fridays.', 16, 1)
        ROLLBACK TRANSACTION
    END
END

Go 

-- 12 / Prevents entering more than 10 listings for the same employee on the same day --
CREATE OR ALTER TRIGGER trg_Limit_Employee_Listings
ON Listing
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT Employee_ID
        FROM Listing
        WHERE CAST(Date AS DATE) = CAST(GETDATE() AS DATE)
        GROUP BY Employee_ID
        HAVING COUNT(*) >= 10
    )
    BEGIN
        RAISERROR('Employee cannot handle more than 10 listings per day.', 16, 1)
        ROLLBACK TRANSACTION
    END
END

Go


-- 13 / Creates a backup copy of the old property data in the Property_Backup table --
CREATE OR ALTER TRIGGER trg_Backup_Property_Before_Update
ON Property
FOR UPDATE
AS    
BEGIN
    INSERT INTO Property_Backup (ID, Type, Area, Status, Price, Backup_Date)
    SELECT ID, Type, Area, Status, Price, GETDATE()
    FROM DELETED
END

Go

-- 14 / You cannot delete an owner who still has properties --
CREATE OR ALTER TRIGGER trg_Prevent_Delete_Owner_With_Properties
ON Owner
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM DELETED D
        JOIN Property P ON D.ID = P.Owner_ID
    )
    BEGIN
        RAISERROR('Cannot delete owner who still owns properties.', 16, 1)
        RETURN
    END

    DELETE FROM Owner WHERE ID IN (SELECT ID FROM DELETED)
END

GO

-- 15 / Prevents appointment conflicts for the same client --
CREATE OR ALTER TRIGGER trg_No_Duplicate_Appointments_For_Client
ON Appointment
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN Appointment A ON I.Client_ID = A.Client_ID AND I.Date = A.Date
    )
    BEGIN
        RAISERROR('Client already has an appointment on this date.', 16, 1)
        ROLLBACK TRANSACTION
    END
END

Go

-- 16 / Validates the existence of the type before insertion --
CREATE OR ALTER TRIGGER trg_Property_Type_Required
ON Property
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM INSERTED WHERE [Type] IS NULL OR LTRIM(RTRIM([Type])) = ''
    )
    BEGIN
        RAISERROR('Property type is required.', 16, 1)
        ROLLBACK TRANSACTION
    END
END

Go

-- 17 / Ensures there is no manipulation or significant underpricing --
CREATE OR ALTER TRIGGER trg_Prevent_Major_Price_Cut
ON Property
FOR UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN DELETED D ON I.ID = D.ID
        WHERE I.Price < D.Price * 0.5
    )
    BEGIN
        RAISERROR('Price cannot be reduced by more than 50%.', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO

-- 18 / Set_Commercial --
CREATE OR ALTER TRIGGER Set_Commercial
ON Property
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON

    UPDATE P
    SET 
        Room = 1,
        Bathroom = 0,
        Price = FLOOR(RAND(CHECKSUM(NEWID())) * (100000 - 40000 + 1)) + 40000
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Commercial'

    UPDATE P
    SET Area = FLOOR(RAND(CHECKSUM(NEWID())) * (65 - 45 + 1)) + 45
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Commercial'
END
GO

-- 19 / Set_Apartment --
CREATE OR ALTER TRIGGER Set_Apartment
ON Property
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON

    UPDATE P
    SET 
        Room = FLOOR(RAND(CHECKSUM(NEWID())) *  2) + 1,
        Bathroom = FLOOR(RAND(CHECKSUM(NEWID())) * 1) +1,
        Price = FLOOR(RAND(CHECKSUM(NEWID())) * (150000 - 100001 + 1)) + 100001
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Apartment'

    UPDATE P
    SET Area = P.Room * 45
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Apartment'
END
GO

-- 20 / Set_Single_Family --
CREATE OR ALTER TRIGGER Set_Single_Family
ON Property
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON

    UPDATE P
    SET
        Room = FLOOR(RAND(CHECKSUM(NEWID())) * (4 - 3 + 1)) + 3, 
        Bathroom = FLOOR(RAND(CHECKSUM(NEWID())) * 2) + 1,              
        Price = FLOOR(RAND(CHECKSUM(NEWID())) * (350000 - 150001 + 1)) + 150001
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Single_Family'

    UPDATE P
    SET Area = P.Room * 45 
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Single_Family'
END
GO

-- 21 / Set_Multi_Family --
CREATE OR ALTER TRIGGER Set_Multi_Family
ON Property
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON

    UPDATE P
    SET 
        Room = FLOOR(RAND(CHECKSUM(NEWID())) * (6 - 5 + 1)) + 5,
        Bathroom = FLOOR(RAND(CHECKSUM(NEWID())) * (3 - 2 + 1)) + 2,
        Price = FLOOR(RAND(CHECKSUM(NEWID())) * (650000 - 350001 + 1)) + 350001
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Multi_Family'

    UPDATE P
    SET Area = P.Room * 45
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Multi_Family'
END
GO

-- 22 / Set_Townhouse --
CREATE OR ALTER TRIGGER Set_Townhouse
ON Property
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON

    UPDATE P
    SET 
        Room = FLOOR(RAND(CHECKSUM(NEWID())) * (10 - 7 + 1)) + 7,
        Bathroom = FLOOR(RAND(CHECKSUM(NEWID())) * (5 - 4 + 1)) + 4,
        Price = FLOOR(RAND(CHECKSUM(NEWID())) * (1100000 - 650001 + 1)) + 650001
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Townhouse'

    UPDATE P
    SET Area = P.Room * 45
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Townhouse'
END
GO

-- 23 / Set_Condo --
CREATE OR ALTER TRIGGER Set_Condo
ON Property
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON

    UPDATE P
    SET 
        Room = FLOOR(RAND(CHECKSUM(NEWID())) * (16 - 11 + 1)) + 11,
        Bathroom = FLOOR(RAND(CHECKSUM(NEWID())) * (10 - 6 + 1)) + 6,
        Price = FLOOR(RAND(CHECKSUM(NEWID())) * (20000000 - 1100001 + 1)) + 1100001
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Condo'

    UPDATE P
    SET Area = p.Room * 45
    FROM Property P
    INNER JOIN inserted i ON P.ID = i.ID
    WHERE i.Type = 'Condo'
END

Go

-- 24 / Calculate Profit , Employee Commission , Broker Commission , Amount To Owner --
CREATE OR ALTER TRIGGER Insert_Payment
ON Payment
AFTER INSERT
AS
BEGIN

    UPDATE p
    SET 
        p.Profit = 
            CASE 
                WHEN (
                    SELECT COUNT(*) 
                    FROM Payment p2 
                    WHERE p2.Property_ID = i.Property_ID
                    AND p2.Movement_Type = 'OUT'
                ) = 2 THEN pr.Price * 0.05  
                ELSE pr.Price * 0.07        
            END,
        p.Employee_Commission = pr.Price * 0.03,
        p.Broker_Commission = NULL,
        p.Amount_To_Owner = NULL
    FROM Payment p
    JOIN inserted i ON p.ID = i.ID
    JOIN Property pr ON i.Property_ID = pr.ID
    WHERE i.Movement_Type = 'IN'

    UPDATE p
    SET 
        p.Profit = NULL,
        p.Employee_Commission = NULL,
        p.Broker_Commission = pr.Price * 0.02,
        p.Amount_To_Owner = NULL
    FROM Payment p
    JOIN inserted i ON p.ID = i.ID
    JOIN Property pr ON i.Property_ID = pr.ID
    WHERE i.Movement_Type = 'OUT' AND i.Related_Type = 'Broker'


    UPDATE p
    SET 
        p.Profit = NULL,
        p.Employee_Commission = NULL,
        p.Broker_Commission = NULL,
        p.Amount_To_Owner = 
            CASE 
                WHEN (
                    SELECT COUNT(*) 
                    FROM Payment p2 
                    WHERE p2.Property_ID = i.Property_ID
                    AND p2.Movement_Type = 'OUT'
                ) = 2 THEN pr.Price - (pr.Price * 0.05 + pr.Price * 0.03 + pr.Price * 0.02)
                ELSE pr.Price - (pr.Price * 0.07 + pr.Price * 0.03)
            END
    FROM Payment p
    JOIN inserted i ON p.ID = i.ID
    JOIN Property pr ON i.Property_ID = pr.ID
    WHERE i.Movement_Type = 'OUT' AND i.Related_Type = 'Owner'
END
GO
