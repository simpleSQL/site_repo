/*Define Variables*/
:ON ERROR EXIT
:SETVAR Primary ""
:SETVAR Secondary ""
:SETVAR DbName ""
:SETVAR BkupDir ""
:SETVAR DataDir	""
:SETVAR LogDir	""
 
SET NOCOUNT ON;
 
:CONNECT  $(Primary)
/*Turn Off Database Log Backup Job on Primary*/ 
	EXEC msdb.dbo.sp_update_job @job_name='Backup Database Logs',@enabled = 0 
GO	
/*Backup Database on Primary*/
	BACKUP DATABASE [$(DbName)] 
	TO DISK = '$(BkupDir)\$(DbName)\$(Primary)_post_refresh_backupAG.bak' with init;	
	GO
	BACKUP LOG  [$(DbName)] 
	TO DISK = '$(BkupDir)\$(DbName)\$(Primary)_post_refresh_backupAG.trn';
GO 
 
/*Connect to Secondary*/
:CONNECT $(Secondary)
/*Check If Database Exists on Secondary and Delete If It Does */	
	IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = '$(DbName)')
	BEGIN 
	   BEGIN TRY 
		   EXEC msdb.dbo.sp_delete_database_backuphistory @database_name ='$(DbName)'   
 
		   DROP DATABASE $(DbName);	   
	   END TRY
	   BEGIN CATCH 
			DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;  		
			SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity =
				ERROR_SEVERITY(), @ErrorState = ERROR_STATE();  
			RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);  
	   END CATCH 
	END 
 
/*Restore Prviouly Taken Backups to Secondary */
	RESTORE DATABASE [$(DbName)] 
	FROM DISK = '$(BkupDir)\$(DbName)\$(Primary)_post_refresh_backupAG.bak' 
     with NORECOVERY, STATS=4
	,MOVE '$(DbName)' TO '$(DataDir)\$(DbName).MDF'
	,MOVE '$(DbName)_log' TO '$(LogDir)\$(DbName)_log.LDF'
	GO
	RESTORE LOG [$(DbName)] 
	FROM DISK = '$(BkupDir)\$(DbName)\$(Primary)_post_refresh_backupAG.trn' 
	WITH NORECOVERY
GO 
WAITFOR DELAY '00:00:30'; 
/*Connect to Primary*/
:CONNECT  $(Primary)
	ALTER AVAILABILITY GROUP [$(Primary)] ADD DATABASE [$(DbName)]; 	
GO	
:CONNECT $(Secondary)	
	WAITFOR DELAY '00:00:20';
	ALTER DATABASE [$(DbName)] SET HADR AVAILABILITY GROUP = [$(Primary)];
	GO
	WAITFOR DELAY '00:00:10';
	ALTER DATABASE [$(DbName)] SET HADR RESUME; 
GO
:CONNECT  $(Primary)
	EXEC msdb.dbo.sp_update_job @job_name='Backup Database Logs',@enabled = 1
GO