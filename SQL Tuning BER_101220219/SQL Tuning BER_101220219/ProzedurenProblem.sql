--Proc generiert den Plan beim ersten Aufruf 
--der Parameter ist entscheidend ob Seek oder Scan
--Proc wird immer denselben Plan verwenden
--Vorteil kann zum Nachteil werden, wenn der Plan aber mit anderen Parametern 
--nicht ok ist.


--id < 2 = 1 Datensatz
create proc idsuche @par int
as
select * from ku5 where id < @par
--SEEK
exec idsuche 2


set statistics io, time on

--SEEK
select * from ku5 where id < 2


--immer noch SSEK
exec idsuche 10000000
--1 MIO Seiten statt 42000!!!!


dbcc freeproccache

--Plan neu
exec idsuche 1000000 --SCAN

--aber auch hier scan

exec idsuche 2 

--aber keine ABfrage bräuchte mehr als 42000 Seiten.. KOmpromiss


--TIPP:: QUery Store kann das gut herausfinden



set statistics io, time on

--