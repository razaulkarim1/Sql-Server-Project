/*

SQL Project
Online Electric Service Providing System
Trainee Name: Razaul Karim

								
*/


------ Building Objects ------

USE master
GO

DROP DATABASE IF EXISTS OnlineElectricServiceProvSystem
GO

CREATE DATABASE OnlineElectricServiceProvSystem
ON
(
	NAME = OnlineElectricServiceProvSystem_data,
	FILENAME= 'D:\OnlineElectricServiceProvSystem_data.mdf',
	SIZE = 100mb,
	MAXSIZE = 200mb,
	FILEGROWTH = 10%
)
LOG ON
(
	NAME = OnlineElectricServiceProvSystem_log,
	FILENAME= 'D:\OnlineElectricServiceProvSystem_log.ldf',
	SIZE = 50mb,
	MAXSIZE = 100mb,
	FILEGROWTH = 5%
)
GO

USE OnlineElectricServiceProvSystem
GO

CREATE TABLE tblServices
(
	serviceId INT IDENTITY PRIMARY KEY,
	serviceName NVARCHAR (30) NOT NULL
)
GO


SELECT * FROM tblServices
GO

CREATE TABLE tblOrder
(
	orderId INT IDENTITY (1000,1) PRIMARY KEY,
	orderName VARCHAR (50) NOT NULL,
	orderPrice MONEY CHECK (orderPrice > 200),
	locationName NVARCHAR (100) NOT NULL
)
GO


               /****  Find Out Total OrderPrice of Sellers
                      by creating Scalar-Valued Function  ****/

CREATE FUNCTION fnSellerWiseTotalOrderValue (@sellerId INT)
RETURNS MONEY
AS
	BEGIN
		DECLARE @totalOrders INT
		SELECT @totalOrders = SUM(o.orderPrice) FROM tblSellRecieveOrder so
		INNER JOIN tblSeller ts ON so.sellerId=ts.sellerId
		INNER JOIN tblOrder o ON so.orderId=o.orderId
		WHERE ts.sellerId = @sellerId
		RETURN @totalOrders
	END
GO



				/***  Find Out Total OrderPrice of Sellers
                      by creating Inline Table-valued Function  ****/

CREATE FUNCTION fnSellerWiseTotalWithTableValuedFunction (@sellerId INT)
RETURNS TABLE
AS
RETURN	
(		
		SELECT  SUM(o.orderPrice) 'Total Price' FROM tblSellRecieveOrder so
		INNER JOIN tblSeller ts ON so.sellerId=ts.sellerId
		INNER JOIN tblOrder o ON so.orderId=o.orderId
		WHERE ts.sellerId = @sellerId
)	
GO




                     /***  Find Out Total OrderPrice of Sellers by creating
							Multi-statement Table-valued Function      ****/

CREATE FUNCTION fnSellerWiseTotalWithMultiStateMentFunction (@sellerId INT)
RETURNS @totalOrderPrice TABLE
(
	sellerId INT,
	sellerName NVARCHAR (15),
	totalPrice MONEY
)
AS
BEGIN
	INSERT INTO @totalOrderPrice
	SELECT so.sellerId, ts.sellerName, SUM(o.orderPrice) FROM tblSellRecieveOrder so
	INNER JOIN tblSeller ts ON so.sellerId=ts.sellerId
	INNER JOIN tblOrder o ON so.orderId=o.orderId
	WHERE so.sellerId = @sellerId
	GROUP BY so.sellerId,.sellerName
	RETURN
END
GO





SELECT * FROM tblOrder
GO

CREATE TABLE tblServiceOrder
(
	orderId INT REFERENCES tblOrder (orderId),
	serviceId INT REFERENCES tblServices (serviceId),
	PRIMARY KEY (serviceId, orderId)
)
GO

CREATE TABLE tblCity
(
	cityId INT IDENTITY PRIMARY KEY,
	cityName NVARCHAR (15) NOT NULL
)
GO

CREATE TABLE tblCustomer
(
	customerId INT IDENTITY (1200,1) PRIMARY KEY,
	customerName NVARCHAR (20) NOT NULL,
	custAddress NVARCHAR (100) NOT NULL,
	mobile NVARCHAR (14) UNIQUE NOT NULL
)
GO


/*
	Create Instead of Trigger to Input data Into tblCustomer
*/

CREATE VIEW vTblCustomerInsert
AS
	SELECT customerName, custAddress, mobile FROM tblCustomer
GO

CREATE TRIGGER trCustomerInsert
ON vTblCustomerInsert
INSTEAD OF INSERT
AS
BEGIN
	INSERT INTO tblCustomer (customerName,custAddress,mobile)
	SELECT customerName,custAddress,mobile FROM inserted
END
GO

SELECT * FROM tblCustomer
SELECT * FROM vTblCustomerInsert
GO

INSERT INTO vTblCustomerInsert VALUES ('Md Ahnaf','Dhaka Medical Collage','03125694012')
INSERT INTO vTblCustomerInsert VALUES ('Azim Uddin','West Raja Bazar, Farmgate','07125094012')
GO



/*
	Create Instead of Trigger to Update data in tblCustomer
*/

CREATE VIEW vTblCustomerUpdate
AS
	SELECT customerId, customerName, custAddress, mobile FROM tblCustomer
GO

CREATE TRIGGER trCustomerTableUpdate
ON vTblCustomerUpdate
INSTEAD OF UPDATE
AS
BEGIN
	IF UPDATE (customerId)
		BEGIN
			RAISERROR ('CustomerId not changeable',16,1)
			RETURN
		END
	IF UPDATE (customerName)
		BEGIN
			UPDATE tblCustomer
			SET customerName = inserted.customerName FROM inserted
			INNER JOIN tblCustomer on inserted.customerName=tblCustomer.customerName
		END
	IF UPDATE (custAddress)
		BEGIN
			UPDATE tblCustomer
			SET custAddress = inserted.custAddress FROM inserted
			INNER JOIN tblCustomer on inserted.custAddress=tblCustomer.custAddress
		END
	IF UPDATE (mobile)
		BEGIN
			UPDATE tblCustomer
			SET mobile = inserted.mobile FROM inserted
			INNER JOIN tblCustomer on inserted.mobile=tblCustomer.mobile
		END
END
GO

SELECT * FROM tblCustomer
SELECT * FROM vTblCustomerUpdate
GO

UPDATE vTblCustomerUpdate SET customerName='MD Azim', custAddress = 'West Raja Bazar, Sher-e-Bangla Nagar', mobile='01772509403'
WHERE customerId = 1203
GO




CREATE TABLE tblCustomerCity
(
	customerId INT REFERENCES tblCustomer (customerId),
	cityId INT REFERENCES tblCity (cityId),
	PRIMARY KEY (customerId, cityId)
)
GO



/*
	Select Into Statement
*/

SELECT * INTO tblCustomerCityInfo
FROM tblCustomerCity
GO




CREATE TABLE tblCustOrder
(
	customerId INT REFERENCES tblCustomer (customerId),
	orderId INT REFERENCES tblOrder (orderId),
	orderDate DATE NOT NULL,
	PRIMARY KEY (customerId, orderId)
)
GO



/* 
	Create Store Procedure to Insert Data into tblOrder 
*/

CREATE PROC spTblOrder @orderName NVARCHAR (50),
					   @orderPrice MONEY,
					   @locationName NVARCHAR (100)
AS
INSERT INTO tblOrder(orderName,orderPrice,locationName)
VALUES (@orderName,@orderPrice,@locationName)
GO


/* 
	Create Store Procedure to Delete Data from tblOrder 
*/

CREATE PROC spTblOrderDelete @orderId INT
AS
IF (@orderId>1000)
	BEGIN
		DELETE tblOrder
		WHERE orderId = @orderId
	END
GO




CREATE TABLE tblDesignation
(
	desigId INT IDENTITY PRIMARY KEY,
	desigName NVARCHAR (20) NOT NULL
)
GO


/*
	Creating Index On tblDesignation
*/

CREATE NONCLUSTERED INDEX ix_desigName
ON tblDesignation (desigName)
GO




CREATE TABLE tblGender
(
	genderId INT IDENTITY PRIMARY KEY,
	genderName NVARCHAR (6) NOT NULL
)
GO


/* 
	Preventing Insert, Update and Delete on tblGender
*/

CREATE TRIGGER trTblGenderPreventModification
ON tblGender
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	PRINT 'Do not try to modify tblGender'
	ROLLBACK TRANSACTION
END
GO

DELETE tblGender WHERE genderId = 1
GO




CREATE TABLE tblReligion
(
	religionId INT IDENTITY PRIMARY KEY,
	religionName NVARCHAR (15)
)
GO


/* 
	Preventing Insert, Update and Delete on tblReligion
*/

CREATE TRIGGER trTblReligionPreventModification
ON tblReligion
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	PRINT 'Do not try to modify tblGender'
	ROLLBACK TRANSACTION
END
GO

DELETE tblReligion WHERE religionId = 1
GO



CREATE TABLE tblSeller
(
	sellerId INT IDENTITY (2000,1) PRIMARY KEY,
	sellerName NVARCHAR (30) NOT NULL,
	sellerAddress NVARCHAR (100) NOT NULL,
	dob DATE NOT NULL,
	mobile NVARCHAR (14) UNIQUE NOT NULL,
	nid CHAR (13) UNIQUE NOT NULL CHECK (nid LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	email NVARCHAR (50) UNIQUE NULL,
	experience INT NOT NULL CHECK (experience>=2)
)
GO


--------- Create Store Procedure to Insert Data with Default  -----------
----------Value and Procedural Integrity into tblSeller------------------

CREATE PROC spTblSeller @sellerName NVARCHAR (30),
						@sellerAddress NVARCHAR (100),
						@dob DATE,
						@mobile NVARCHAR (14),
						@nid NVARCHAR (13),
						@email NVARCHAR (50) = NULL,
						@experience INT
AS
IF (@experience>2)
	BEGIN
		INSERT INTO tblSeller (sellerName,sellerAddress,dob,mobile,nid,email,experience)
		VALUES (@sellerName,@sellerAddress,@dob,@mobile,@nid,@email,@experience)
	END
ELSE
	BEGIN
		RAISERROR ('Your inserting data is invalid',16,1)
		ROLLBACK TRANSACTION
	END
GO



--------- Create Store Procedure to apply Output Perameter into tblOrder------------

CREATE PROC spTblSellerWithOutPutPerameter
			@sellerName NVARCHAR (30),
			@sellerAddress NVARCHAR (100),
			@dob DATE,
			@mobile NVARCHAR (14),
			@nid NVARCHAR (13),
			@email NVARCHAR (50),
			@experience INT,
			@id INT OUTPUT
AS
INSERT INTO tblSeller (sellerName, sellerAddress,dob,mobile,nid,email,experience)
VALUES (@sellerName,@sellerAddress,@dob,@mobile,@nid,@email,@experience)
SELECT @id = IDENT_CURRENT ('tblSeller')
GO

DECLARE @sellerId INT
EXEC spTblSellerWithOutPutPerameter 'Abdul Halim','Abdullahpur','1991/05/13','01402697810',5014879643254,'abdullatif@gmail.com',3,@sellerId OUTPUT
SELECT @sellerId 'New Id'
GO





CREATE TABLE tblSellCityDesigGender
(
	sellerId INT REFERENCES tblSeller (sellerId),
	cityId INT REFERENCES tblCity (cityId),
	desigId INT REFERENCES tblDesignation (desigId),
	genderId INT REFERENCES tblGender (genderId),
	religionId INT REFERENCES tblReligion (religionId),
	PRIMARY KEY (sellerId,cityId,desigId,genderId,religionId)
)
GO


/*
	Create View on tblSeller and tblSeller link table
*/

CREATE VIEW vTblSellerDetails
AS
SELECT ts.sellerId,ts.sellerName,ts.sellerAddress,ts.dob, ts.mobile,ts.nid,ts.email,
ts.experience, tg.cityId, tg.desigId, tg.genderId, tg.religionId FROM tblSeller ts
INNER JOIN tblSellCityDesigGender tg ON ts.sellerId=tg.sellerId
GO



CREATE TABLE tblSellRecieveOrder
(
	orderId INT REFERENCES tblOrder (orderId),
	sellerId INT REFERENCES tblSeller (sellerId),
	PRIMARY KEY (orderId,sellerId)
)
GO
--------- End of Building Object here -----------




--------- Insert Data Into tblServices ----------
INSERT INTO tblServices VALUES
('Electric'),
('Mechanic'),
('Cumputer'),
('Refregerator'),
('instrument Decoration'),
('Pipe Fitting')
GO

SELECT * FROM tblServices
GO

--------- Insert Data Into tblOrder------------
INSERT INTO tblOrder (orderName,orderPrice,locationName) VALUES 
('Simple Electric Problem Solving',500.00,'39 Lake Circus Road'),
('Hardware Servicing',1000.00,'50 Kazi Naz Avenue, Dhaka'),
('Refregerator Servicing',400.00,'Badalpur,Azmirganj'),
('Bed Room Decoration', 2000.00,'Mainamati Bazar'),
('Motor Problem Solving',500.00,'21 Main Road, Gulistan')
GO

SELECT * FROM tblOrder
GO

-------- Insert Data Into spTblOrder -----------
EXEC spTblOrder 'Need to Solve simple plumbing problem',1000.00,'Agargaon Colony School, Agargaon'
EXEC spTblOrder 'Freeze problem fixed asap',700.00,'3rd Floor, New Complex, SSK Road, Feni'
EXEC spTblOrder 'An adroit meachine mechanic required',3000.00,'Flat no 5, Nilkhet junctino, Nilkhet'
EXEC spTblOrder 'I want to repair my ciling fan',300.00,'2nd floor, House no 15, adjacent to Bashundahra shopping Mall'
EXEC spTblOrder 'Do you have enough skill in dyning decoration?',3500.00,'115 Bangla Motor, Dhaka'
EXEC spTblOrder 'My Computer behaves rudely, can anyone fix it?',1500.00,'Habiganj main road, Habiganj'
EXEC spTblOrder 'Want to repair my house pipe line',1000.00,'House no 13, Gulshan'
EXEC spTblOrder 'Need an skilled room decorator',4000.00,'Chandina bazar, Chandina, Cumilla'
GO

SELECT * FROM tblOrder
SELECT * FROM tblServices
GO

--------- Insert Data Into tblServiceOrder------------
INSERT INTO tblServiceOrder VALUES
(1000,1),
(1001,3),
(1002,4),
(1003,5),
(1004,6)
GO

SELECT * FROM tblServiceOrder
GO

--------- Insert Data Into tblCity------------
INSERT INTO tblCity VALUES
('Dhaka'),
('Chattagram'),
('Cumilla'),
('Sylhet'),
('Feni'),
('Rajshahi'),
('Brishal'),
('Khulna')
GO

INSERT INTO tblCity VALUES
('Dinajpur')
GO

SELECT * FROM tblCity
GO

--------- Insert Data Into tblCustomer------------
INSERT INTO tblCustomer VALUES
('Md Arman','Dhanmondhi 32','01841639135'),
('Amit Hasan','50 Kazi Naz Avenue, Dhaka','01831639935'),
('Md Abrar','Azmirganj, Sylhet','01741639085'),
('Akbar Ali','Mainamati Bazar, Cumilla','01921639135'),
('Fahim Ashrap','Gulistan, Dhaka','01621631035'),
('Muhtasib Billah','Agargaon Colony School, Agargaon','01521639135'),
('Faruqe Ahmed','3rd Floor, New Complex, SSK Road, Feni','01321639335'),
('Ajmal Hossain','Nilkhet junctino, Nilkhet','01721639335'),
('Mukbul Mia','House no 15, adjacent to Bashundahra shopping Mall','01421639035'),
('Sandip Barman','115 Bangla Motor, Dhaka','01421639935'),
('Akhil Uddin','Habiganj main road, Habiganj','01821639735'),
('Borhan Mia','House no 13, Gulshan','01521639235')
GO

SELECT * FROM tblCustomer
SELECT * FROM tblCity
GO

--------- Insert Data Into tblCustomerCity------------
INSERT INTO tblCustomerCity VALUES
(1200,1),
(1201,1),
(1202,4),
(1203,3),
(1204,1),
(1205,1),
(1206,5),
(1207,1),
(1208,1),
(1209,1),
(1210,4),
(1211,1)
GO

SELECT * FROM tblCustomerCity
GO

SELECT * FROM tblOrder
SELECT * FROM tblCustomer
GO

--------- Insert Data Into tblCustOrder------------
INSERT INTO tblCustOrder VALUES
(1200,1000,'2020/04/10'),
(1201,1001,'2020/07/10'),
(1202,1002,'2020/04/27'),
(1203,1003,'2020/09/09'),
(1204,1004,'2020/04/13'),
(1205,1005,'2020/05/20'),
(1206,1006,'2020/07/29'),
(1207,1007,'2020/05/18'),
(1208,1008,'2020/09/10'),
(1209,1009,'2020/04/25'),
(1210,1010,'2020/07/07'),
(1211,1011,'2020/04/30')
GO

SELECT * FROM tblCustOrder
GO

--------- Insert Data Into tblDesignation------------
INSERT INTO tblDesignation VALUES
('Electrician'),
('Mechanic'),
('Computer Technician'),
('Refregerator Repair'),
('Home Decorator'),
('Plumber')
GO

--------- Insert Data Into tblGender------------
INSERT INTO tblGender VALUES
('Male'),
('Female'),
('Other')
GO

--------- Insert Data Into tblReligion------------
INSERT INTO tblReligion VALUES
('Islam'),
('Hidhu'),
('Bhuddist'),
('Christian'),
('Other')
GO

--------- Insert Data Into tblSeller------------
INSERT INTO tblSeller VALUES
('Ashiqur Rahman','125 Tejgaon, Sher-e-Bangla Nagar, Farmgate','1992/01/18','01306718594',5087149874124,'ashiq302@gmail.com',2)
GO

INSERT INTO tblSeller VALUES
('Saiful Islam','Chandina Bazar, Chandina, Cumilla','1996/10/21','01406718594',5086149854036,'sislam450@gmail.com',4),
('Sadman Hossen','Sonargaon, Narayanganj','2000/02/06','01706717594',5186139854412,'sadman.h20@gmail.com',3),
('Kazi Nazrul','Circuit House Road, Mohipal','2001/03/06','01806717594',5086139054789,'knazrul115@gmail.com',2)
GO

-------- Insert Data Into spTblSeller -------
EXEC spTblSeller 'Kamrul Hasan','Gazipur chowrasta, Gazipur','1988/05/19','01840563214',5083831236541,'khasan70@gmail.com',6
EXEC spTblSeller 'Taquir Mahmud','Mainamati Bazar','1989/05/22','01405632140',5082831230541,'taquir@gmail.com',3
EXEC spTblSeller 'Md Mustafa','Sakpura, Boalkhali','1996/06/28','01340563214',5083821226541,'m.mustafa@gmail.com',4
EXEC spTblSeller 'Firoz Ahmed','Kushtia Sadar, Kushtia','1992/11/20','01640563214',5073831216541,'fahmed20@gmail.com',3
EXEC spTblSeller 'Mushfiq Mia','Araihazar, Narayanganj','1996/07/19','01540569213',5083831236049,'mushfiq12@gmail.com',5
EXEC spTblSeller 'Ratul Hasan','Badalpur,Azmirganj','1980/09/01','01440563214',5085831236341,'ratul1120@gmail.com',8
EXEC spTblSeller 'Md Manik','Tangi, Gazipur','1993/07/11','01740563214',5093831236541,'manik@gmail.com',4
EXEC spTblSeller 'Moshiur Rahman','Barasat, Anwara','1991/03/03','01440569214',5083830236541,'moshiur990@gmail.com',4
EXEC spTblSeller 'Liyakot Ali','Habiganj main road, Habiganj','2002/06/03','01340561015',5081831236549,'liyakot@gmail.com',6
EXEC spTblSeller 'Chanchal Hasan','Ward no - 85, Jatrabari','1985/09/16','01540563214',5083835236548,'chanchal@gmail.com',7
GO

SELECT * FROM tblSeller
SELECT * FROM tblSellCityDesigGender
GO

--------- Insert Data Into tblSellCityDesigGender------------
SELECT * FROM tblOrder
SELECT * FROM tblSeller
SELECT * FROM tblCity
SELECT * FROM tblDesignation
GO

INSERT INTO tblSellCityDesigGender VALUES
(2000,1,1,1,1),
(2001,3,5,1,1),
(2002,1,3,1,1),
(2003,5,4,1,1),
(2004,1,2,1,1),
(2005,5,4,1,1),
(2006,2,3,1,1),
(2007,8,6,1,1),
(2008,1,6,1,1),
(2009,4,3,1,1),
(2010,1,5,1,1),
(2011,2,3,1,1)
GO

INSERT INTO tblSellCityDesigGender VALUES
(2012,4,4,1,1)
GO




SELECT * FROM tblSellCityDesigGender
GO

--------- Insert Data Into tblSellRecieveOrder------------
SELECT * FROM tblOrder
SELECT * FROM tblSeller
SELECT * FROM tblSellCityDesigGender
GO

INSERT INTO tblSellRecieveOrder VALUES
(1000,2000),
(1001,2002),
(1002,2012),
(1003,2001),
(1004,2004),
(1005,2008),
(1006,2003),
(1007,2004),
(1008,2000),
(1009,2010),
(1010,2009),
(1011,2008),
(1012,2001)
GO


SELECT * FROM tblSellRecieveOrder
GO
