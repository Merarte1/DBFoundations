--*************************************************************************--
-- Title: Assignment06
-- Author: MArteaga
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,MArteaga,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MArteaga')
	 Begin 
	  Alter Database [Assignment06DB_MArteaga] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MArteaga;
	 End
	Create Database Assignment06DB_MArteaga;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MArteaga;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Go
Create View vCategories With SchemaBinding
As
Select CategoryID, CategoryName 
From dbo.Categories;
Go

Create View vProducts With SchemaBinding
As
Select ProductID, ProductName, CategoryID, UnitPrice 
From dbo.Products;
Go

Create View vEmployees With SchemaBinding
As
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID 
From dbo.Employees;
Go

Create View vInventories With SchemaBinding
As
Select InventoryID, InventoryDate, EmployeeID, ProductID, Count 
From dbo.Inventories;
Go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On dbo.Categories to Public;
Grant Select On vCategories to Public;
Go

Deny Select On dbo.Products to Public;
Grant Select On vProducts to Public;
Go

Deny Select On dbo.Employees to Public;
Grant Select On vEmployees to Public;
Go

Deny Select On dbo.Inventories to Public;
Grant Select On vInventories to Public;
Go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
/*
-- See Categories and Products views

Select * From vCategories;
Select * From vProducts;
Go

-- See required columns and join views

Select CategoryName, ProductName, UnitPrice 
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID;
Go

-- Order by category and product, and see top 100,000 as we are working with views

Select Top 100000
CategoryName, ProductName, UnitPrice 
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Order by CategoryName, ProductName;
Go

-- Adjust format

Select Top 100000
 CategoryName
, ProductName
, UnitPrice 
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Order by CategoryName, ProductName;
Go

-- Create the new view

Create View vProductsByCategories
As
Select Top 100000
 CategoryName
, ProductName
, UnitPrice 
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Order by CategoryName, ProductName;
Go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- See the products and inventories views

Select * From vProducts;
Select * From vInventories;
Go

-- See the required columns and join the views

Select ProductName, InventoryDate, Count
From vProducts
Join vInventories
On vProducts.ProductID = vInventories.ProductID;
Go

-- Order by product, date and count, and see top 100,000 as we are working with views

Select Top 100000
ProductName, InventoryDate, Count
From vProducts
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Order by ProductName, InventoryDate, Count;
Go

-- Adjust format

Select Top 100000
 ProductName
,InventoryDate
,Count
From vProducts
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Order by ProductName, InventoryDate, Count;
Go

-- Create the new view
*/
Create View vInventoriesByProductsByDates
As
Select Top 100000
 ProductName
,InventoryDate
,Count
From vProducts
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Order by ProductName, InventoryDate, Count;
Go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
/*
-- See the inventories and employees views

Select * From vInventories;
Select * From vEmployees;
Go

-- See the required columns and join the views

Select InventoryDate, EmployeeFirstName, EmployeeLastName
From vInventories
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID;
Go

-- See the employees names and last names in the same column

Select InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vInventories
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID;
Go

-- Order by inventory date, and see top 100,000 as we are working with views

Select Top 100000
InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vInventories
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID
Order by InventoryDate;
Go

-- Select distinct results

Select Distinct Top 100000
InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vInventories
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID
Order by InventoryDate;
Go

-- Adjust format

Select Distinct Top 100000
 InventoryDate
 ,EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vInventories
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID
Order by InventoryDate;
Go
*/
-- Create the new view

Create View vInventoriesByEmployeesByDates
As
Select Distinct Top 100000
 InventoryDate
 ,EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vInventories
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID
Order by InventoryDate;
Go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
/*
-- See the Categories, Products and Inventories views

Select * From vCategories;
Select * From vProducts;
Select * From vInventories;
Go

-- See the required columns and join the views

Select CategoryName, ProductName, InventoryDate, Count
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID;
Go

-- Order by category, product, date and count, and see top 100,000 as we are working with views

Select Top 100000
CategoryName, ProductName, InventoryDate, Count
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Order by CategoryName, ProductName, InventoryDate, Count;
Go

-- Adjust format

Select Top 100000
 CategoryName
,ProductName
,InventoryDate
,Count
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Order by CategoryName, ProductName, InventoryDate, Count;
Go
*/
-- Create the new view

Create View vInventoriesByProductsByCategories
As
Select Top 100000
 CategoryName
,ProductName
,InventoryDate
,Count
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Order by CategoryName, ProductName, InventoryDate, Count;
Go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
/*
-- See the Categories, Products, Inventories and Employees views

Select * From vCategories;
Select * From vProducts;
Select * From vInventories;
Select * From vEmployees;
Go

-- See the required columns and join the views

Select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName, EmployeeLastName
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID;
Go

-- See the employees first and last names in the same column

Select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID;
Go

-- Order by date, category, product and employee, and see top 100,000 as we are working with views

Select Top 100000
CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID
Order by InventoryDate, CategoryName, ProductName, EmployeeName;
Go

-- Adjust format

Select Top 100000
 CategoryName
 ,ProductName
 ,InventoryDate
 ,Count
 ,EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID
Order by InventoryDate, CategoryName, ProductName, EmployeeName;
Go
*/
-- Create the new view

Create View vInventoriesByProductsByEmployees
As
Select Top 100000
 CategoryName
 ,ProductName
 ,InventoryDate
 ,Count
 ,EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID
Order by InventoryDate, CategoryName, ProductName, EmployeeName;
Go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
/*
-- See the Categories, Products, Inventories and Employees views

Select * From vCategories;
Select * From vProducts;
Select * From vInventories;
Select * From vEmployees;
Go

-- See the required columns and join the views

Select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName, EmployeeLastName
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID;
Go

-- See the first and last names of the employees in the same column

Select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vCategories
Join vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join vInventories
On vProducts.ProductID = vInventories.ProductID
Join vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID;
Go

-- Filter results for the products Chai and Chang

Select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vCategories as c
Join vProducts as p
On c.CategoryID = p.CategoryID
Join vInventories as i
On p.ProductID = i.ProductID
Join vEmployees as e
On e.EmployeeID = e.EmployeeID
Where p.ProductID In (Select ProductID From vProducts Where ProductName = 'Chai' or ProductName =  'Chang');
Go

-- Order by date, category and product, and see top 100,000 as we are working with views

Select Top 100000
CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vCategories as c
Join vProducts as p
On c.CategoryID = p.CategoryID
Join vInventories as i
On p.ProductID = i.ProductID
Join vEmployees as e
On i.EmployeeID = e.EmployeeID
Where p.ProductID In (Select ProductID From vProducts Where ProductName = 'Chai' or ProductName =  'Chang')
Order by InventoryDate, CategoryName, ProductName;
Go

-- Adjust format

Select Top 100000
 CategoryName
 ,ProductName
 ,InventoryDate
 ,Count
 ,EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vCategories as c
Join vProducts as p
On c.CategoryID = p.CategoryID
Join vInventories as i
On p.ProductID = i.ProductID
Join vEmployees as e
On i.EmployeeID = e.EmployeeID
Where p.ProductID In (Select ProductID From vProducts Where ProductName = 'Chai' or ProductName =  'Chang')
Order by InventoryDate, CategoryName, ProductName;
Go
*/
-- Create the new view.

Create View vInventoriesForChaiAndChangByEmployees
As
Select Top 100000
 CategoryName
 ,ProductName
 ,InventoryDate
 ,Count
 ,EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From vCategories as c
Join vProducts as p
On c.CategoryID = p.CategoryID
Join vInventories as i
On p.ProductID = i.ProductID
Join vEmployees as e
On i.EmployeeID = e.EmployeeID
Where p.ProductID In (Select ProductID From vProducts Where ProductName = 'Chai' or ProductName =  'Chang')
Order by InventoryDate, CategoryName, ProductName;
Go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
/*
-- See the Employees view

Select * From vEmployees;
Go

-- See the Manager ID next to the Employee ID for clarity

Select ManagerID, * From vEmployees;
Go

-- Self Join the views with aliases. For now just looking at the IDs.

Select mgr.ManagerID, emp.EmployeeID From vEmployees as emp
Join vEmployees as mgr
On emp.EmployeeID = mgr.ManagerID;
Go

-- Add the columns for employee and manager names for further clarity. Adjusting format at this point as otherwise the code gets too long.

Select 
  mgr.ManagerID
 ,mgr.EmployeeFirstName as [ManagerFirstName]
 ,mgr.EmployeeLastName as [ManagerLastName]
 ,emp.EmployeeID
 ,emp.EmployeeFirstName
 ,emp.EmployeeLastName
From vEmployees as emp
Join vEmployees as mgr
On mgr.EmployeeID = emp.ManagerID;
Go

-- Join the columns to see employee names and manager names in 1 column and remove the ID columns, which are no longer necessary

Select 
  mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName as [Manager]
 ,emp.EmployeeFirstName + ' ' + emp.EmployeeLastName as [Employee]
From vEmployees as emp
Join vEmployees as mgr
On mgr.EmployeeID = emp.ManagerID;
Go

-- Order the results by manager and employee. Select the top 100,000 as we are working with views.

Select Top 100000
 mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName as [Manager]
 ,emp.EmployeeFirstName + ' ' + emp.EmployeeLastName as [Employee]
From vEmployees as emp
Join vEmployees as mgr
On mgr.EmployeeID = emp.ManagerID
Order by Manager, Employee;
Go
*/
-- Create the new view

Create View vEmployeesByManager
As
Select Top 100000
 mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName as [Manager]
 ,emp.EmployeeFirstName + ' ' + emp.EmployeeLastName as [Employee]
From vEmployees as emp
Join vEmployees as mgr
On mgr.EmployeeID = emp.ManagerID
Order by Manager, Employee;
Go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
/*
-- See the Categories, Products, Inventories and Employees views

Select * From vCategories;
Select * From vProducts;
Select * From vInventories;
Select * From vEmployees;
Go

-- See the required columns and join the views. Seeing the employee and manager names in single columns at this point for clarity.

Select c.CategoryID, CategoryName, p.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, e.EmployeeID,
  emp.EmployeeFirstName + ' ' + emp.EmployeeLastName as [Employee]
  ,mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName as [Manager]
From vCategories as c
Right Outer Join vProducts as p
On c.CategoryID = p.CategoryID
Right Outer Join vInventories as i
On p.ProductID = i.ProductID
Right Outer Join vEmployees as e
On i.EmployeeID = e.EmployeeID
Join vEmployees as emp
On emp.EmployeeID = e.EmployeeID
Join vEmployees as mgr
On emp.EmployeeID = mgr.EmployeeID;
Go

-- Order the results by category, product, inventoryID, employee and manager. Select the top 100,000 as we are working with views.

Select Top 100000
  c.CategoryID, c.CategoryName, p.ProductID, p.ProductName, p.UnitPrice, i.InventoryID, i.InventoryDate, i.Count, e.EmployeeID,
  e.EmployeeFirstName + ' ' + emp.EmployeeLastName as [Employee]
  ,mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName as [Manager]
From vCategories as c
Join vProducts as p
On c.CategoryID = p.CategoryID
Join vInventories as i
On p.ProductID = i.ProductID
Join vEmployees as e
On i.EmployeeID = e.EmployeeID
Join vEmployees as emp
On i.EmployeeID = emp.EmployeeID
Join vEmployees as mgr
On e.ManagerID = mgr.EmployeeID
Order by CategoryName, ProductName, InventoryID, Employee, Manager;
Go

-- Adjust format

Select Top 100000
  c.CategoryID
  ,c.CategoryName
  ,p.ProductID
  ,p.ProductName
  ,p.UnitPrice
  ,i.InventoryID
  ,i.InventoryDate
  ,i.Count
  ,e.EmployeeID
  ,e.EmployeeFirstName + ' ' + emp.EmployeeLastName as [Employee]
  ,mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName as [Manager]
From vCategories as c
Join vProducts as p
On c.CategoryID = p.CategoryID
Join vInventories as i
On p.ProductID = i.ProductID
Join vEmployees as e
On i.EmployeeID = e.EmployeeID
Join vEmployees as emp
On i.EmployeeID = emp.EmployeeID
Join vEmployees as mgr
On e.ManagerID = mgr.EmployeeID
Order by CategoryName, ProductName, InventoryID, Employee, Manager;
Go

-- Create the new view. Note that this view does not match the result in the assignment from line 7 onwards, but it matches
-- the rest of the instructions. I am inferring that the result in the assignment may have not been updated.
*/
Create View vInventoriesByProductsByCategoriesByEmployees
As
Select Top 100000
  c.CategoryID
  ,c.CategoryName
  ,p.ProductID
  ,p.ProductName
  ,p.UnitPrice
  ,i.InventoryID
  ,i.InventoryDate
  ,i.Count
  ,e.EmployeeID
  ,e.EmployeeFirstName + ' ' + emp.EmployeeLastName as [Employee]
  ,mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName as [Manager]
From vCategories as c
Join vProducts as p
On c.CategoryID = p.CategoryID
Join vInventories as i
On p.ProductID = i.ProductID
Join vEmployees as e
On i.EmployeeID = e.EmployeeID
Join vEmployees as emp
On i.EmployeeID = emp.EmployeeID
Join vEmployees as mgr
On e.ManagerID = mgr.EmployeeID
Order by CategoryName, ProductName, InventoryID, Employee, Manager;
Go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/