use master;
 
set nocount on
 
if object_id('tempdb..#last_accessed_times') is not null
 
drop table #last_accessed_times
 
create table #last_accessed_times
 
(
 
[server_name] varchar(255)
 
, [database_name] varchar(255)
 
, [last_user_seek] datetime
 
, [last_user_scan] datetime
 
, [last_user_lookup] datetime
 
, [last_user_update] datetime
 
)
 
declare @get_last_accessed_time varchar(max)
 
set @get_last_accessed_time = ''
 
select @get_last_accessed_time = @get_last_accessed_time +
 
'use [' +  sd.name + '];' + char(10) +
 
'select ' + char(10) + '
 
''Server Name'' = @@servername ' + char(10) + '
 
, ''Database Name'' = upper(db_name(db_id())) ' + char(10) + '
 
, ''Last User Seek'' = max(sddius.last_user_seek) ' + char(10) + '
 
, ''Last User Scan'' = max(sddius.last_user_scan) ' + char(10) + '
 
, ''Last User Lookup'' = max(sddius.last_user_lookup) '+ char(10) + '
 
, ''Last User Update'' = max(sddius.last_user_update) '+ char(10) + '
 
from
 
sys.dm_db_index_usage_stats sddius
 
where
 
sddius.database_id = db_id()' + char(10)
 
from master.sys.databases sd
 
where sd.database_id > 4
 
order by sd.name asc
 
insert into #last_accessed_times
 
exec (@get_last_accessed_time)
 
select
 
[server_name] = upper([server_name])
 
, [database_name] = upper([database_name])
 
, [last_user_seek] = left([last_user_seek], 19)
 
, [last_user_scan] = left([last_user_scan], 19)
 
, [last_user_lookup] = left([last_user_lookup], 19)
 
, [last_user_update] = left([last_user_update], 19)
 
from
 
#last_accessed_times
 
order by
 
[server_name]
 
, [database_name] asc
 
drop table #last_accessed_times
