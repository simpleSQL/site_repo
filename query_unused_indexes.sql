SELECT 
o.name AS ObjectName,
i.name AS IndexName,
o.create_date AS CreationDate,
i.index_id AS IndexID,
u.user_seeks AS UserSeeks,
u.user_scans AS UserScans,
u.user_lookups AS UserLookups,
u.user_updates AS UserUpdates,
p.TableRows
FROM sys.dm_db_index_usage_stats u
INNER JOIN sys.indexes i ON i.index_id = u.index_id 
	AND u.OBJECT_ID = i.OBJECT_ID
INNER JOIN sys.objects o ON u.OBJECT_ID = o.OBJECT_ID
INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
FROM sys.partitions p 
GROUP BY p.index_id, p.OBJECT_ID) p
	ON p.index_id = u.index_id 
	AND u.OBJECT_ID = p.OBJECT_ID
WHERE OBJECTPROPERTY(u.OBJECT_ID,'IsUserTable') = 1
AND u.database_id = DB_ID()
AND i.type_desc ='nonclustered'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
AND o.is_ms_shipped <> 1
ORDER BY (u.user_seeks + u.user_scans + u.user_lookups)