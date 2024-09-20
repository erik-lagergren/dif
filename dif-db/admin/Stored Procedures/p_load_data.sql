CREATE PROCEDURE [admin].[p_load_data]
    @source varchar(200),
    @target varchar(200), -- 'schema.table'
    @batch_id varchar(30)
AS
BEGIN
    declare @source_schema varchar(200) = substring(@source, 1,  charindex('.', @source)-1)
    declare @source_table varchar(200) = substring(@source, charindex('.', @source)+1, len(@source))
    declare @target_schema varchar(200) = substring(@target, 1,  charindex('.', @target)-1)
    declare @target_table varchar(200) = substring(@target, charindex('.', @target)+1, len(@target))
    declare @target_key varchar(200) = @target_table + '_key'
    declare @sql_merge nvarchar(max)  
    declare @columnlist varchar(max)
    declare @setlist varchar(max)
    declare @sourcelist varchar(max)
    declare @ignorelist varchar(100)
    declare @batch_condition varchar(100)

    if @batch_id is null 
        set @batch_condition = ' '
    else
        set @batch_condition = ' where batch_id = ' + @batch_id

    begin TRY
        -- insert columns
        set @ignorelist = ''           -- all columns
        exec admin.p_get_column_list 
            @schema_name = @target_schema, 
            @table_name = @target_table, 
            @ignore_list = @ignorelist,
            @column_list = @columnlist out
            
        -- source insert columns
        set @sourcelist = 's.' + Replace(@columnlist, ',', ',s.')

        -- update set list
        set @ignorelist = @target_key           -- set columns
        exec admin.p_get_column_list 
            @schema_name = @target_schema, 
            @table_name = @target_table, 
            @ignore_list = @ignorelist,
            @update_bit = 1,
            @column_list = @setlist out
            
        set @sql_merge = '
        MERGE INTO 
            ' + @target + ' AS t 
        USING 
            (select * from ' + @source + @batch_condition + ') AS s 
        ON 
            t.' + @target_key + ' = s.' + @target_key + '
        WHEN MATCHED AND t.rowhash <> s.rowhash THEN 
            UPDATE 
                SET ' +  @setlist + '
        WHEN NOT MATCHED BY TARGET THEN     
            INSERT ( ' + @columnlist + ') 
            VALUES ( ' + @sourcelist + ');'

        print(@sql_merge)
        exec sp_executesql @sql_merge
               
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