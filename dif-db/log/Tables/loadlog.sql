CREATE TABLE [log].[loadlog] (
    [loadlog_id]    AS            (((([source]+'|')+[target])+'|')+CONVERT([varchar](27),[start_time])),
    [source]        VARCHAR (200) NOT NULL,
    [target]        VARCHAR (200) NOT NULL,
    [start_time]    DATETIME2 (7) NOT NULL,
    [end_time]      DATETIME2 (7) NULL,
    [duration]      AS            (datediff(second,[start_time],[end_time])),
    [status]        VARCHAR (30)  NULL,
    [error_message] VARCHAR (500) NULL,
    [inserted_rows] INT           NULL,
    [updated_rows]  INT           NULL,
    [deleted_rows]  INT           NULL
);

