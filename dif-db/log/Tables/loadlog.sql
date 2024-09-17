CREATE TABLE [log].[loadlog] (
    [loadlog_id]  INT           IDENTITY (1, 1) NOT NULL,
    [logid]       VARCHAR (500) NULL,
    [source]      VARCHAR (100) NULL,
    [source_type] VARCHAR (100) NULL,
    [target]      VARCHAR (100) NULL,
    [message]     VARCHAR (300) NULL,
    [phase]       VARCHAR (100) NULL,
    [time]        DATETIME2 (7) NULL,
    [status]      VARCHAR (100) NULL,
    [inserts]     INT           NULL,
    [updates]     INT           NULL,
    [deletes]     INT           NULL,
    PRIMARY KEY CLUSTERED ([loadlog_id] ASC)
);

