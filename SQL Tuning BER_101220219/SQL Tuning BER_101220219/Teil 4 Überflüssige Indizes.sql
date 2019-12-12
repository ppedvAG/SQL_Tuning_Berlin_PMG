--Überflüssige Indizes identifizieren

--kosten Performance bei INSERT / DELETE

--Systemsichten
-- select * from sys.dm_db_index_physical_Stats verknüpft mikt sys.indexes


select object_name(i.object_id) as TableName
      ,i.type_desc,i.name
      ,us.user_seeks, us.user_scans
      ,us.user_lookups,us.user_updates
      ,us.last_user_scan, us.last_user_update
  from sys.indexes as i
       left outer join sys.dm_db_index_usage_stats as us
                    on i.index_id=us.index_id
                   and i.object_id=us.object_id
 where objectproperty(i.object_id, 'IsUserTable') = 1
go

--Optimierer entscheidet sich für Index-scan , wenn die der günstiger als Table-scan ist
-- user_scan, index_scan  ..nie gebrauchte Indizes evtl löschen
-- user_scan, index_scan  .. besser als table scan


set nocount on

if (object_id('T1', 'U') is not null)
  drop table T1
go
create table T1
 (
  c1 int not null identity(1,1) primary key
 ,c2 nvarchar(80) not null default '*'
 ,c3 char(500) not null default '*'
 )
go

insert T1(c2) values(newid()) 
go 3

insert T1(c2) select newid() from T1
go 10



--Welcher INDEX?

set statistics io on
 select c2 from T1 where c2 like '%BCD%'
set statistics io off
go

--clustered!


--nicht gruppierter auf c2
create index Ix1 on T1(c2)
go


select c2 from T1 where c2 like 'BCD%'
go

--Lookup Vorgänge
--warum?

select * from T1 where c2 like 'BCD%'






200 MB HEAP
1 CL
2NCL
--> 363 MB

Offline  online

TDB  ohne TDB

Offline ohne TEMPDB  890 MB

Online mit Temdb     1100 MB


select * into ku5 from ku1

select * from ku5 where country = 'UK'


select * from ku5 where country = 'XYZ'


--Stat aktualisierung: 20% Änderungen + 500 + Abfrage

--Brent Ozar_ sp_blitzIndex

--SQlservercentral.com --Stairways


--1 NF Atomar

2.4.2016 -- 1--- 2016

andreasr    ppedv.de


--pdf zum download

--Profiler Perfmon





