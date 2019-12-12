--RecoveryModel

--Simpel: Datenverlust, wenn SQL crasht
--INS UP DEL werden protokolliert, aber nach CHeckpoint, werden die TX aus
--dem Log entfernt. Spätestens beim FUllbackup


--BULK
--Bulk wird rudimentär prtokolliert, aber das Log wird nicht geleert.
--Restore per Log/Logbackup möglich


--Full
--Bulk wird ausführlich protokolliert
--auf Sek restore möglich

--bei Full und Bulk muss eine TLogSicherung regelmäßig erfolgen, damit das Log geleert wird


--LOG restore..dauert solange wie die Aktionen im LOG dauerten

--Das Log kann nur durch Backups gellert werden--> Regelmäßg ..kurze Abstände
--> Faustregel: wie groß darf der max Zeitraum des Datenverlusts sein = LogBackup


--Intern werden Logfiles durch virtuelle Logfiles verwaltet
--Logfiles können nur um  VLFs gekürzt werden
--aber auch nur dann , wenn diese keine offenen TX enthalten

--Faustregel: pro 10GB 50 VLFs
--die Anzahl ist abhängig von den Wachstumsraten

--Falls zuviele:

--Backup Log
--Checkpoint
--keine offene TX
--Shrinken des Logs
--Wachstumsraten anpassen  (1 GB)

--variables to hold each 'iteration'  
declare @query varchar(100)  
declare @dbname sysname  
declare @vlfs int  
  
--table variable used to 'loop' over databases  
declare @databases table (dbname sysname)  
insert into @databases  
--only choose online databases  
select name from sys.databases where state = 0  
  
--table variable to hold results  
declare @vlfcounts table  
    (dbname sysname,  
    vlfcount int)  
  
 
 
--table variable to capture DBCC loginfo output  
--changes in the output of DBCC loginfo from SQL2012 mean we have to determine the version 
 
declare @MajorVersion tinyint  
set @MajorVersion = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))-1) 

if @MajorVersion < 11 -- pre-SQL2012 
begin 
    declare @dbccloginfo table  
    (  
        fileid smallint,  
        file_size bigint,  
        start_offset bigint,  
        fseqno int,  
        [status] tinyint,  
        parity tinyint,  
        create_lsn numeric(25,0)  
    )  
  
    while exists(select top 1 dbname from @databases)  
    begin  
  
        set @dbname = (select top 1 dbname from @databases)  
        set @query = 'dbcc loginfo (' + '''' + @dbname + ''') '  
  
        insert into @dbccloginfo  
        exec (@query)  
  
        set @vlfs = @@rowcount  
  
        insert @vlfcounts  
        values(@dbname, @vlfs)  
  
        delete from @databases where dbname = @dbname  
  
    end --while 
end 
else 
begin 
    declare @dbccloginfo2012 table  
    (  
        RecoveryUnitId int, 
        fileid smallint,  
        file_size bigint,  
        start_offset bigint,  
        fseqno int,  
        [status] tinyint,  
        parity tinyint,  
        create_lsn numeric(25,0)  
    )  
  
    while exists(select top 1 dbname from @databases)  
    begin  
  
        set @dbname = (select top 1 dbname from @databases)  
        set @query = 'dbcc loginfo (' + '''' + @dbname + ''') '  
  
        insert into @dbccloginfo2012  
        exec (@query)  
  
        set @vlfs = @@rowcount  
  
        insert @vlfcounts  
        values(@dbname, @vlfs)  
  
        delete from @databases where dbname = @dbname  
  
    end --while 
end 
  
--output the full list  
select dbname, vlfcount  
from @vlfcounts  
order by dbname