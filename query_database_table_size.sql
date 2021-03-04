USE [] --specify database name
 GO
 SELECT 
 s.Name AS SchemaName,
 t.Name AS TableName,
 p.rows AS RowCounts,
 CAST(ROUND((SUM(a.used_pages) / 128.00), 2) AS NUMERIC(32,2)) AS Used_MB,
 CAST(ROUND((SUM(a.total_pages) - SUM(a.used_pages)) / 128.00, 2) AS NUMERIC(36,2)) AS Unused_MB,
 CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS NUMERIC(36,2)) AS Total_MB
 FROM sys.tables t
 INNER JOIN sys.indexes i ON t.OBJECT_ID = i.OBJECT_ID
 INNER JOIN sys.partitions p ON i.OBJECT_ID = p.OBJECT_ID AND i.index_id = p.index_id
 INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
 INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
 --WHERE t.Name IN ('')
 GROUP BY t.Name, s.Name, p.Rows
 ORDER BY Total_MB DESC
 GO