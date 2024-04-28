/*
Who: KGuite
What: Stored Procedure to create DimState table and insert data from FactUemployment
When: 4/26/2024
Note: 55 states
*/






USE [Crimson_Katharine]
GO

DROP PROCEDURE dbo.sp_DimState


CREATE PROCEDURE [dbo].[sp_DimState]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Transaction starts
        BEGIN TRANSACTION;

        -- Step 2: Drop Table if exists
        DROP TABLE IF EXISTS [dbo].[DimState];

        -- Step 3: Create Table with updated types
        CREATE TABLE [dbo].[DimState]
        (
            DimState_Key int IDENTITY (1,1), -- future Surrogate Key
            State nvarchar(50)
        );

        -- Step 4: Write ETL fixing datatypes
        INSERT INTO [dbo].[DimState]
        SELECT DISTINCT
            [State]
        FROM [Crimson_Katharine].[dbo].[FactUnemployment] FACT WITH (NOLOCK);

        -- Commit transaction if everything is fine
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction if error occurs
        ROLLBACK TRANSACTION;
        THROW; -- Re-throw caught exception
    END CATCH
END
GO

-- Check if the procedure exists before executing
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_DimState' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    EXEC [dbo].[sp_DimState];
    SELECT * FROM dbo.DimState; -- This should show all 55 "states" as expected
END
ELSE
BEGIN
    PRINT 'Stored procedure does not exist.';
END
GO


