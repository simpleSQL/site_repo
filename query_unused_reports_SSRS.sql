USE [ReportServer] --Specify SSRS Database
GO 
DECLARE @NumDays INT 
 
SET @NumDays = 365 --Specify Number of Days
 
SELECT Name,
	Path,
	LastUsedDate,
	DaysNotUsed=DATEDIFF(DD,LastUsedDate,GETDATE()) 
  FROM dbo.catalog c 
  INNER JOIN (SELECT ReportID,LastUsedDate= MAX(timestart)  
         FROM dbo.executionlog 
         GROUP BY ReportID) e ON c.ItemID = e.ReportID 
WHERE DATEDIFF(DD,LastUsedDate,GETDATE()) >= @NumDays
ORDER BY DaysNotUsed DESC