/*

SQL Project
Online Electric Service Providing System
Trainee Name: Razaul Karim

								
*/

USE OnlineElectricServiceProvSystem
GO

------ Write Simple Query to scratch out Total OrderPrice -----
SELECT SUM(orderPrice) 'Total Price' FROM tblOrder
GO


------ Write Full Join Query to find out Customer, Order and Seller Wise order Details -----
SELECT c.customerId, o.orderId,s.sellerId,o.orderPrice, co.orderDate FROM tblCustomer c
JOIN tblCustOrder co ON c.customerId=co.customerId
JOIN tblOrder o ON co.orderId=o.orderId
JOIN tblSellRecieveOrder so ON o.orderId=so.orderId
JOIN tblSeller s ON so.sellerId=s.sellerId
GO


------Write Left Join Query-------
SELECT o.orderId,o.orderName,s.serviceId,o.locationName,o.orderPrice FROM tblOrder o
INNER JOIN tblServiceOrder s ON o.orderId=s.orderId
WHERE o.orderPrice>1000
GO


------Write a join query to scratch out CustomerWise and SellerWise Order 
------list with aggregate function -----
SELECT c.customerId, SUM(o.orderPrice) 'CustomerWise TotalOrder', s.sellerId,
SUM(o.orderPrice) 'SellerWise TotalOrder' FROM tblCustomer c
INNER JOIN tblCustOrder co ON c.customerId=co.customerId
INNER JOIN tblOrder o ON co.orderId=o.orderId
INNER JOIN tblSellRecieveOrder so ON o.orderId=so.orderId
INNER JOIN tblSeller s ON so.sellerId=s.sellerId
GROUP BY c.customerId,s.sellerId
GO


------Write a join query to scratch out CustomerWise and SellerWise Order 
------list with aggregate function and Rollup -----
SELECT c.customerId, SUM(o.orderPrice) 'CustomerWise TotalOrder', s.sellerId,
SUM(o.orderPrice) 'SellerWise TotalOrder' FROM tblCustomer c
INNER JOIN tblCustOrder co ON c.customerId=co.customerId
INNER JOIN tblOrder o ON co.orderId=o.orderId
INNER JOIN tblSellRecieveOrder so ON o.orderId=so.orderId
INNER JOIN tblSeller s ON so.sellerId=s.sellerId
GROUP BY ROLLUP (c.customerId,s.sellerId)
GO


------Write a join query to scratch out CustomerWise and SellerWise Order 
------list with aggregate function and Cube -----
SELECT c.customerId, SUM(o.orderPrice) 'CustomerWise TotalOrder', s.sellerId,
SUM(o.orderPrice) 'SellerWise TotalOrder' FROM tblCustomer c
INNER JOIN tblCustOrder co ON c.customerId=co.customerId
INNER JOIN tblOrder o ON co.orderId=o.orderId
INNER JOIN tblSellRecieveOrder so ON o.orderId=so.orderId
INNER JOIN tblSeller s ON so.sellerId=s.sellerId
GROUP BY CUBE (c.customerId,s.sellerId)
GO


------ Testing View ------
SELECT * FROM vTblSellerDetails
GO


------ Testing Select Statement -----
SELECT * FROM tblCustomerCityInfo
GO


------ Testing Select Statement -----
EXEC sp_helpindex tblDesignation
GO


------Test Store Procedure by Inserting Data into tblOrder ------
EXEC spTblOrder 'Need an skilled Plumber',900.00,'Bangla bazar, Dhaka'
GO


------Test Store Procedure by Inserting Data into tblOrder ------
DELETE  tblOrder WHERE orderId = 1013
GO


-----Testing Total OrderPrice of Sellers by creating Scalar-Valued Function 
SELECT dbo.fnSellerWiseTotalOrderValue (2001) 'Total Order'
GO


----- Testing Total OrderPrice of Sellers by creating Inline Table-valued Function-----
SELECT * FROM dbo.fnSellerWiseTotalWithTableValuedFunction (2000)
GO



----- Total OrderPrice of Sellers by creating Multi-statement Table-valued Function---
SELECT * FROM dbo.fnSellerWiseTotalWithMultiStateMentFunction (2001)
GO




-----Testing preventing Insert, Update and Delete on tblGender----
DELETE tblGender WHERE genderId = 1
GO


-----Testing preventing Insert, Update and Delete on tblGender----
DELETE tblReligion WHERE religionId = 1
GO


---------Creates CTE on tblOrder and tbluCustomer------


WITH tblCustomerInfo AS
(
	SELECT customerId, customerName, custAddress, mobile FROM tblCustomer
	WHERE customerId IN (SELECT customerId FROM tblOrder)
),
tblSellerInfo AS
(
	SELECT sellerId, sellerName, sellerAddress, dob FROM tblSeller
)
SELECT tblCustomerInfo.customerId,tblCustomerInfo.customerName FROM tblCustomerInfo
GO


----- Using of Cast ----
SELECT CAST(GETDATE() AS DATE) 'Date'
GO


----- Using Convert ------
SELECT CONVERT(TIME,GETDATE(),1) 'Time'
GO


----- Using Case Function ---
SELECT cityId, 
	CASE cityId
		WHEN 1 THEN 'It is a luxarious'
		WHEN 2 THEN 'It is riched with nature'
		WHEN 3 THEN 'Famous for sweets'
	else 'Not applicable'
	END 
FROM tblCity
GO
