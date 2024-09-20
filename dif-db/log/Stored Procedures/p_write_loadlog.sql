CREATE PROCEDURE [log].[p_write_loadlog]
    @source varchar(200),
    @target varchar(200),
    @start_time datetime2,
    @end_time datetime2 = null,
    @error_message varchar(500) = null,
    @inserted_rows INT = null,
    @updated_rows int = null,
    @deleted_rows int = null
AS
BEGIN

    declare @status varchar(100)

    if @error_message is not null
        set @status = 'Failed'
    else if @end_time is not NULL
        set @status = 'Completed'
    else
        set @status = 'Running'

    begin TRY
        insert into [log].[loadlog] (
            [source], 
            [target], 
            [start_time], 
            [end_time], 
            [status], 
            [error_message], 
            [inserted_rows], 
            [updated_rows], 
            [deleted_rows] ) 
        select 
            @source, 
            @target, 
            @start_time, 
            @end_time, 
            @status, 
            @error_message, 
            @inserted_rows, 
            @updated_rows, 
            @deleted_rows

    end TRY
    begin CATCH

        declare @error_text nvarchar(500)
        declare @procedure_name nvarchar(200)
    
        set @procedure_name = OBJECT_NAME(@@PROCID); 
        set @error_text = @procedure_name + ': ' + ERROR_MESSAGE()

        print(@error_text)
    
        RAISERROR(
            @error_text,
            10,         -- ERROR_SEVERITY()
            1)          -- ERROR_STATE()

    end CATCH     
 end