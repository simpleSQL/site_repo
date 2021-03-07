USE []  --INSERT DATABASE HERE
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
GO
 
CREATE	Procedure [dbo].[]  --INSERT PROC NAME HERE
 
AS
 
/* **********************************************************************
Author:
Creation Date:D
Desc: 
*************************************************************************
Sample
======
exec --INSERT PROC NAME AND PARAMETERS HERE
GRANT EXECUTE on [PROC NAME HERE] TO public
 
Change History
DATE		CHANGED BY		CHANGE CODE		DESCRIPTION
	
*/
BEGIN
DECLARE @transtate BIT
IF @@TRANCOUNT = 0
BEGIN
	SET @transtate = 1
	BEGIN TRANSACTION transtate
END
 
BEGIN TRY
 
/*INSERT PROC CODE HERE*/
	
	IF @transtate = 1 
        AND XACT_STATE() = 1
        COMMIT TRANSACTION transtate
END TRY
BEGIN CATCH
 
DECLARE @Error_Message VARCHAR(5000)
DECLARE @Error_Severity INT
DECLARE @Error_State INT
 
SELECT @Error_Message = ERROR_MESSAGE()
SELECT @Error_Severity = ERROR_SEVERITY()
SELECT @Error_State = ERROR_STATE()
 
   IF @transtate = 1 
   AND XACT_STATE() <> 0
   ROLLBACK TRANSACTION
 
RAISERROR (@Error_Message, @Error_Severity, @Error_State)
 
END CATCH
END
 
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED