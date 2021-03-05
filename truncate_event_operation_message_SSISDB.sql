USE [SSISDB]
GO

TRUNCATE TABLE [internal].[event_message_context]

ALTER TABLE [internal].[event_message_context] 
DROP CONSTRAINT [FK_EventMessageContext_EventMessageId_EventMessages]
        
TRUNCATE TABLE internal.event_messages
        
ALTER TABLE [internal].[event_message_context]  
WITH CHECK ADD  CONSTRAINT [FK_EventMessageContext_EventMessageId_EventMessages] 
FOREIGN KEY([event_message_id])
REFERENCES [internal].[event_messages] ([event_message_id])
ON DELETE CASCADE
 
ALTER TABLE [internal].[event_messages] 
DROP CONSTRAINT [FK_EventMessages_OperationMessageId_OperationMessage]
        
TRUNCATE TABLE [internal].[operation_messages]
 
ALTER TABLE [internal].[event_messages]  
WITH CHECK ADD  CONSTRAINT [FK_EventMessages_OperationMessageId_OperationMessage] 
FOREIGN KEY([event_message_id])
REFERENCES [internal].[operation_messages] ([operation_message_id])
ON DELETE CASCADE
