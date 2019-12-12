--DB Settings

create database ardb

--wieviele fehler haben wir gemacht?
--StdSettings
/*
Pfade

Anfangsgröße:		8 MB Daten und Log     (früher: 5 und 2)
Wachstumsraten:     64MB Daten und Logfile (früher 1 MB und 10%)


--Logfile: virt Logfiles

--------10MB------
x x x x x x x x x x  1 MB vLogfiles
------------------

bei 100MB
--------------------------------------------------------
x x x x x x x x x x x x x x x x x x x x! x x x x x x x 
--------------------------------------------------------

-------------------TX------------------
  UP -20     UP +20
---------------------------------------


--------------------------------------------------------
x!                x!                      x!              x!
--------------------------------------------------------



*/


use ardb;

---Demotabelle T1
create table t1 (id int identity, spx char(4100))


insert into t1
select 'XY'
GO 20000 

--Frage: wie groß ist theoretisch die Tabelle: 80MB

--select 156* 7 --1 Sekunde
--Clientkommunikation

select * into t2 from t1 --auch in 1 Sekunde möglich!!

--20000 Transaktionen

--aber wieso 160MB statt 80MB


---Verlustrate von ca 49% pro Seite.. muss weg!
--Messen?

dbcc showcontig('t1')
--- Gescannte Seiten.............................: 20000
--- Mittlere Seitendichte (voll).....................: 50.79%

--wie kann man "entlüften"?
--Kompression?

--Zeilenkompression und Seitenkompression
--normalerweise ca 40 bis 60% 


--was passiert nach der Kompression?

--SQL Server RAM: 1000MB
--Abfrage auf T1 (unkomp) : 1160MB!!
--Seiten : 20000  CPU:  125    Dauer:  1395
set statistics io, time on
select * from ardb..t1

--T1 komprimiert

--SQL Server RAM: 
--Abfrage auf T1:     RAM + 0,5MB 
--CPU : mehr   Dauer: kaum eine Änderung (ausser man braucht mehr CPU als Dauer)
--Seiten: 30 Seiten  1.1 in RAM

--Abfragen an kompr Tabellen werden eher schlechter als besser..

--evtl Archivdaten

--absolut transparent für Anwendung!






--















