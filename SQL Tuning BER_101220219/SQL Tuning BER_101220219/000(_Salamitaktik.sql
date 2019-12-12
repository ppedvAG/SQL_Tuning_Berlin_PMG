--Salamitaktik

--TAB A 10000       TAB B 100000

1,5 Sek A



--Umsatz

--Idee: viele kleine Tabellen

create table u2020 (id int identity, spx int, jahr int)
create table u2019 (id int identity, spx int, jahr int)
create table u2018 (id int identity, spx int, jahr int)
create table u2017 (id int identity, spx int, jahr int)


--Wo ist mein Umsatz??


select * from umsatz

create view Umsatz
as
select * from u2020
UNION ALL --keine Suche nach doppelten
Select * from u2019
UNION ALL 
select * from u2018
UNION ALL
select * from u2017



select * from umsatz where jahr = 2019 --bisher 0 gewonnen

create table t4(id int, spx int not null)


--Sicherheit und Kontrolle dass in Jahr nur das jeweile Jahr steht

ALTER TABLE dbo.u2017 ADD CONSTRAINT
	CK_u2017 CHECK (jahr=2017)


ALTER TABLE dbo.u2018 ADD CONSTRAINT
	CK_u2018 CHECK (jahr=2018)



ALTER TABLE dbo.u2019 ADD CONSTRAINT
	CK_u2019 CHECK (jahr=2019)


ALTER TABLE dbo.u2020 ADD CONSTRAINT
	CK_u2020 CHECK (jahr=2020)

--Geht INS UP DEL auf Sichten?

insert into umsatz (id, spx, jahr) values (1,100,2017)

select * from umsatz where jahr = 2017



--Dateigruppen
--DB: mind.1 Snapshot
--mdf   ldf
--ndf ndf ndf mdf .. ldf

create table t6 (id int) on HOT --= mdf

create table ... on HOT -- HOT Dateigruppe .ndf


-----Partitionierung: 15000 Partitionen

--Nummer int
---------------100----------------------200----------------------------
--         1                 2                    3


--1 = DG1  2 = DG2 3 = DG3


--Partfunktion 

create partition function fZahl(int)
as
RANGE LEFT FOR VALUES (100,200)

select $partition.fZahl(117) --2 

create partition scheme schZahl
as
partition fzahl to (bis100,bis200, rest)
--                      1     2     3


create table ptab (id int, nummer int, spx char(4100)) on schZahl(nummer)


declare @i as int = 0
begin tran
while @i < 20000
	begin
		insert into ptab values(@i, @i, 'xy')
		set @i+=1
	end
end;


--ist das besser
set statistics io, time on
select * from ptab where id = 117

select * from ptab where nummer = 1170

----neue Grenze an 5000

----------100-------------200-----------------------5000--------------------

--F(), Schema, --> Tab niemals
--Reihenfolge: Schema  F()

alter partition scheme schZahl next used bis5000

select $partition.fzahl(nummer) , min(nummer), max(nummer), count(*)
from ptab
group by $partition.fzahl(nummer)

alter partition function fzahl() split range(5000)

select * from ptab where nummer = 7500


--Grenze entfernen
--F()  Schema Tab: Reihenfolge : Tab nie!!....  

alter partition function fZahl() merge Range (100)

--Archivieren

create table archive(id int, nummer int, spx char(4100)) on rest

--Verschieben von Datensätzen

alter table ptab switch partition 3 to archive



select * from archive

--100MB / Sek

--1000000000000000000000000000000000000000000MB--> 0,x Sek




--------------------------------------------------
AXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     
--------------------------------------------------





create partition function fZahl(datetime)
as
RANGE LEFT FOR VALUES ('bis auf ms','')


--AbisM  NbisR  SbisZ
create partition function fZahl(varchar(50))
as
RANGE LEFT FOR VALUES ('N','S')




create partition scheme schZahl
as
partition fzahl to ([PRIMARY],[PRIMARY], [PRIMARY])











