/*
Who: KGuite
When: 4/26/2024
What: Stored procedure to create a FactUnemployment table and insert data from Raw_Unemployment
Notes: 11,609 rows
*/


USE [Crimson_Katharine]
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_FactUnemployment' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    DROP PROCEDURE [dbo].[sp_FactUnemployment];
END
GO

CREATE PROCEDURE [dbo].[sp_FactUnemployment]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Transaction starts
        BEGIN TRANSACTION;
        
        -- Step 2: Drop Table if exists
        DROP TABLE IF EXISTS [dbo].[FactUnemployment];

        -- Step 3: Create Table with updated types
        CREATE TABLE [dbo].[FactUnemployment]
        (
            [FactUnemployment_Key] int IDENTITY (1,1), -- future Surrogate Key
            [State] nvarchar(50),
            [Filed week ended] date,
            [Initial Claims] int,
            [Reflecting Week Ended] date,
            [Continued Claims] int,
            [Covered Employment] int,
            [Insured Unemployment Rate] float
        );

        -- Step 4: Write ETL fixing datatypes
        INSERT INTO [dbo].[FactUnemployment]
            ([State], [Filed week ended], [Initial Claims], [Reflecting Week Ended], [Continued Claims], [Covered Employment], [Insured Unemployment Rate])
        SELECT
            [State],
            CAST([Filed week ended] AS date),
            CAST([Initial Claims] AS INT),
            CAST([Reflecting Week Ended] AS date),
            CAST([Continued Claims] AS INT),
            CAST([Covered Employment] AS INT),
            CAST([Insured Unemployment Rate] AS float)
        FROM [Crimson_Katharine].[dbo].[Raw_Unemployment] RAW WITH (NOLOCK);

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
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_FactUnemployment' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    EXEC [dbo].[sp_FactUnemployment];
    SELECT * FROM dbo.FactUnemployment;
END
ELSE
BEGIN
    PRINT 'Stored procedure does not exist.';
END
GO
