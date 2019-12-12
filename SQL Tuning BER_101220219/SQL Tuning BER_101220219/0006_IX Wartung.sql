/*
Grundeinstellungen Server und DB
MAX Größe  empfehlenswert für das OS

Verzeichnisse

MAXDOP

DB: Idealer Startwert für eine DB

--wie groß in 3 Jahre?

Indizes

*/


--Plan : SEEK.. SCAN

--TABLE SCAN  vs   CL IX SCAN ... s......e...g....l

--IX SCAN vs CL IX SCAN

--IX SEEK 


--NCL --> HEAP x    NCL --> CL IX
--Schreiben lieber auf CL IX oder auf HEAP? .. HEAP
--
--Auswirkung von fehlenden CL IX


set statistics io, time on
select * from ku1 where freight = 1 -- 41621 --56247

dbcc showcontig('ku1') --42185 --veraltet

alter table ku1 add id int identity

select * from ku1 where freight = 1

--forward Record count 14062..die müssen weg!!!
select * from sys.dm_db_index_physical_stats(db_id(), object_id('ku1'), NULL, NULL, 'detailed')

--CL IX--> 43065

--Tipp: gugg mal, hat denn jede Tab eine CL IX



--Wartung von Indizes.. am besten regelmäßig jeden Tag / Nacht
--IX Fragmentierung
--Job per Wartungsplan

--Rebuild > 30%
--Reorg > 10%

--Wartungsplan ab SQL 2016 ok

--Empfehlenswert: Scripte besorgen (Brent Ozar )
select * from sys.dm_db_index_usage_stats

sp_blitzIndex

