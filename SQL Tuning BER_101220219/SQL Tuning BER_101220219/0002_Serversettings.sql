--Serversettings

--Volumewartungstask
--kein "Ausnullen"..schnellere Vergrößerungen der Datendateien
-------------------
xxxxxxxxxxxxxxxxxxxx
-------------------

--Pfad der DBs

SystemDBs

--Trenne Daten von Log pro DB
BenutzerDBdatendateien
BenutzerDBLogDateien

--tempdb fehlt!!--> Idee.. andere HDDs!!
--evtl hat tempdb viel Traffic

--Dateien wie Cores, aber nicht mehr als 8
--Trenne Log von Daten
--T 1117  1118
--gleiche Wachsen der Dateien
--uniform extents


--MaxRAM

--MaxDop

--wieviel CPUs verwenden Abfragen pauscha und wieviel ist gut?

select country, sum(freight) from customers c 
	inner join orders o on c.customerid = o.customerid
--where orderid < 10
group by country

--default
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'5'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'0'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO

--
set statistics io, time on
select country, sum(freight) from customers c 
	inner join orders o on c.customerid = o.customerid
--where orderid < 10
group by country option (maxdop 4)

--
-- 5488 ms, verstrichene Zeit = 723 ms.
--CPU-Zeit = 3390 ms, mit 2 CPU
-- 3921 ms, verstrichene Zeit = 992 ms.  4 CPUs arbeitslos 



USE [Nwind]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 4;
GO


--Messen ..
select * from sys.dm_os_wait_stats


------------Ressource frei------CPU frei
---------------------------------------- wait_time
--                       -------  signal time

--wait_time -siganl time = Wartezeit auf Ressource
--signal time > 25% der Wait_time... CPU Engpass
----evtl viel Paral...??

select * from sys.dm_os_wait_stats where wait_type like 'CX%'


--RAM
--MaxWert : Garantie für andere wie : OS




