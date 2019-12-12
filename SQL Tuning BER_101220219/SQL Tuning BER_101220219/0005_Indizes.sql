--Indizes

/*
x gruppierter IX
x nicht gruppierter IX
--------------------------
x eindeutiger IX
x zusammengesetzter IX
x IX mit eingeschl Spalten
x gefilterten IX
partitionierten IX
x abdeckenden IX
x ind Sicht
---------------------------------
Columnstore IX

--T Scan, CL IX SCAN, CL IX SEEK, NCL IX SEEK

select * from verkauf
--der PK hat die Aufgabe Bez herszustellen, muss aber eindeutig sein
--PK mach timmer gruppierten IX, wenn noch keiner da ist
--Bereichabfrage vermutlich VDatum


delete from customers where customerid = 'BLAUS'--Referenzen werden kontrolliert




*/

SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Customers.ContactTitle, Customers.City, Customers.Country, Orders.EmployeeID, Orders.OrderDate, Orders.Freight, Orders.ShipCity, Orders.ShipCountry, 
                  Employees.LastName, Employees.FirstName, Employees.BirthDate, [Order Details].Quantity, [Order Details].UnitPrice, [Order Details].ProductID, [Order Details].OrderID, Products.ProductName, Products.UnitsInStock
INTO KU1
FROM     Customers INNER JOIN
                  Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
                  Employees ON Orders.EmployeeID = Employees.EmployeeID INNER JOIN
                  [Order Details] ON Orders.OrderID = [Order Details].OrderID INNER JOIN
                  Products ON [Order Details].ProductID = Products.ProductID

--Ziel 1,1 Mio --> 550000

insert into ku1 select * from ku1


set statistics io, time on

--nochmal ne Kopie
select * into ku2 from ku1

--und eine ID rein
alter table ku2 add id int identity

--ohne IX: T SCAN
select id from ku2 where id = 1000 --er weiss dass eine Zeile rauskommt

select * from ku2 where city = 'Berlin'--schätzt 5900 ca von real 6144

select id from ku2 where id = 1000  --Seiten:  56315.. 219ms und 29ms 

--zuerst CL IX festlegen.. Orderdate

--NIX_ID
select id from ku2 where id = 1000 --3 Seiten-- 0 ms 


--Suche mit City.. Lookup in Heap 50% oder teurer
select id, city from ku2 where id =1000 --3 Seiten-- 0 ms 

--besser mit: NIX_ID_CI ---3 Seiten .. reiner IX Seek
select id, city, country from ku2 where id =1000 --3 Seiten-- 0 ms 


--aber , was wenn select *.. in einem zusammengesetzten IX (ID und CI) passen
--nicht mehr als 16 Spalten rein (was bei 20 Spalten??)
--und die Summe der Werte dürfen nicht über 900byte liegen
--in den meisten Fällen reichen 4 Spalten aus...

--NIX_ID_inkl_CI_CY
select id, city, country from ku2 where id =1000 --3 Seiten-- 0 ms 


select country, sum(unitprice*quantity) from ku2
where freight < 1
group by country

CREATE NONCLUSTERED INDEX NIX_FR_INKL_CY_QU_UP
ON [dbo].[ku2] ([Freight])
INCLUDE ([Country],[Quantity],[UnitPrice])

--NIX_FR_inkl_CY_UP_QU


select freight from ku2 where
		country = 'UK' and City = 'London'

--NIX_CI_CY



select freight from ku2 where
		country = 'UK' or  City = 'London'

--NIX_CI_CY evtl 2ten IX...??


--gefilterter IX

--warum alle Datensätze

--Was wäre die Alternative zu NIX_FilterLondon
select country, freight from ku2 where city = 'London'

--NIX_CITY


select country, count(*) from customers
group by country

create view v1
as
select country, count(*) as Anz from customers
group by country

select * from v1

create or alter  view v1 with schemabinding
as
select country, count_big(*) as Anz from dbo.customers
group by country


--mit ind Sicht 0 sek und 2 Seiten
--statt: 67000 und 1300 und 170

--saucoool , aber ... es muss ein count_big entahlten sein

--macht Sinn bei AGG

--1 BILLION DS.. Umsatz pro Land per Ind Sicht..

---Ind Sicht hat aber viele Limits!!


--Spieltabelle für CS
select * into ku3 from ku2

select top 3 * from ku2-- Abfrage : where , Agg, 
--wieviel Stück wurde im Jahr 1996 verkauft pro Produkt

select productname, sum(quantity) from ku2 
	where orderdate between '1.1.1996' and '31.12.1996' --- name like M%   oder left(1,name) = L
group by productname


^--NIX_Odate_inkl_PName_QU

--1570 Seiten.. 16ms und 24ms 

select productname, sum(quantity) from ku3 
	where orderdate between '1.1.1996' and '31.12.1996' --- name like M%   oder left(1,name) = L
group by productname

--WTF..?? 

select productname, sum(quantity) from ku3 
	where orderdate between '1.1.1996' and '31.12.1996' --- name like M%   oder left(1,name) = L
group by productname


select Employeeid, sum(quantity) from ku3 
	where freight< 1--- name like M%   oder left(1,name) = L
group by Employeeid

--WTF x5

--KU3 hat 3,7 MB statt 330MB Daten und 300MB IX
--a) stimmt nicht oder b ) stimmt !!!

--> b!

--dann muss aber komprimiert sein!... aber Page und row 40 bis 60%???

--Wo ist Nachteil...

--Nachteil aller IX
--Schreiben.. INS, up del


--Columnstore: select * from sys.dm_db_column_store_row_group_physical_stats

--