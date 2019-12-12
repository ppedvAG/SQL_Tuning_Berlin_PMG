--Abfragen:

/*

a) adhoc Abfragen
b) Sicht 
c) F()
d) Prozedur

--langsam --> schnell
--c  d   a  b
--b  a   c  d
--c   a|b      d
--d  c   ab



Giftliste
Trigger
F()
Cursor


*/

create view KundenUSA
as
select * from customers where country = 'USA'


select * from kundenUSA

select * from (select * from customers where country = 'USA') as Kundenusa


--