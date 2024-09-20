CREATE PROCEDURE [admin].[p_get_column_list]
    @schema_name varchar(200),
    @table_name varchar(200),
    @update_bit bit = 0,
    @source_prefix varchar(50) = 's',
    @target_prefix varchar(50) = 't',
    @ignore_list varchar(500) = 'rowhash,sourcetag,batch_id',
    @column_list varchar(max) out

AS
BEGIN
    begin TRY
        if @update_bit = 0
            SELECT 
                @column_list = string_agg(COLUMN_NAME, ',')
            FROM 
                INFORMATION_SCHEMA.COLUMNS
            WHERE 
                TABLE_SCHEMA = @schema_name
                and TABLE_NAME = @table_name
                and COLUMN_NAME not in (select value from string_split(@ignore_list,','))
        ELSE -- update list
            SELECT 
                @column_list = string_agg(@target_prefix + '.' + COLUMN_NAME + '=' + @source_prefix + '.' + COLUMN_NAME, ',')
            FROM 
                INFORMATION_SCHEMA.COLUMNS
            WHERE 
                TABLE_SCHEMA = @schema_name
                and TABLE_NAME = @table_name
                and COLUMN_NAME not in (select value from string_split(@ignore_list,','))
    
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