USE Northwind_ROLAP
GO 

CREATE TABLE DDL_Audit_Log (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    EventType NVARCHAR(100),
    ObjectName NVARCHAR(255),
    ObjectType NVARCHAR(100),
    LoginName NVARCHAR(255),
    DatabaseName NVARCHAR(255),
    EventTime DATETIME DEFAULT GETDATE(),
    TSQLCommand NVARCHAR(MAX)
);


CREATE TRIGGER trg_DDL_Audit
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE,
    CREATE_VIEW, ALTER_VIEW, DROP_VIEW,
    CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO DDL_Audit_Log (
        EventType,
        ObjectName,
        ObjectType,
        LoginName,
        DatabaseName,
        TSQLCommand
    )
    SELECT
        EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)'),
        EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(255)'),
        DB_NAME(),
        EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)');
END;
