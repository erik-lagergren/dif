CREATE PROCEDURE [log].[p_update_loadlog]
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

    begin TRY

        -- Completed
        if @end_time is not null 
        begin
            update 
                log.loadlog 
            set 
                status = 'Completed',
                end_time = @end_time
            where
                source = @source
                and target = @target
                and start_time = @start_time
        end

        -- Row counts
        if @inserted_rows is not null or @updated_rows is not null or @deleted_rows is not null 
        begin
            update 
                log.loadlog 
            set 
                inserted_rows = @inserted_rows,
                updated_rows = @updated_rows,
                deleted_rows = @deleted_rows
            where
                source = @source
                and target = @target
                and start_time = @start_time
        end

        -- Failed
        if @error_message is not null and len(@error_message) > 0
        begin
            update 
                log.loadlog 
            set 
                status = 'Failed',
                error_message = @error_message
            where
                source = @source
                and target = @target
                and start_time = @start_time
        end

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