/**************
*Who: Katharine
*When: 04/16/2024
*What: ETL Process for Raw Fact Covid 
*Notes: Takes a couple minutes to execute. 4.766.736 rows
*
*****************/


USE [Crimson_Katharine]
GO


DROP PROCEDURE [dbo].[sp_FactCovid]
GO

CREATE PROCEDURE [dbo].[sp_FactCovid]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Transaction starts
        BEGIN TRANSACTION;

        -- Step 2: Drop Table if exists
        DROP TABLE IF EXISTS [dbo].[FactCovid];

        -- Step 3: Create Table with updated types
        CREATE TABLE [dbo].[FactCovid]
        (
            FactCovid_Key int IDENTITY (1,1), -- future Surrogate Key
            ID INT,
            Updated date,
            Confirmed int,
            Confirmed_Change int,
            Deaths int,
            Deaths_Change int,
            Recovered int,
            Recovered_Change int,
            Latitude nvarchar(50),
            Longitude nvarchar(50),
            Iso2 nvarchar(50),
            Iso3 nvarchar(50),
            Country_Region nvarchar(50),
            Admin_Region_1 nvarchar(50),
            Iso_Subdivision nvarchar(50),
            Admin_Region_2 nvarchar(50)
            --,Load_Time date
        );

        -- Step 4: Write ETL fixing datatypes
        INSERT INTO [dbo].[FactCovid]
        SELECT
            CAST([id] AS INT),
            CAST([updated] AS date),
            CAST([confirmed] AS INT),
            CAST([confirmed_change] AS INT),
            CAST([deaths] AS INT),
            CAST([deaths_change] AS INT),
            CAST([recovered] AS INT),
            CAST([recovered_change] AS INT),
            [latitude],
            [longitude],
            [iso2],
            [iso3],
            [country_region],
            [admin_region_1],
            [iso_subdivision],
            [admin_region_2]
            --, CAST([load_time] AS date)
        FROM [Crimson_Katharine].[dbo].[Raw_BingCovid] RAW WITH (NOLOCK);

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
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_FactCovid' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    EXEC [dbo].[sp_FactCovid];
    SELECT * FROM [dbo].[FactCovid]; -- This will show all processed records
END
ELSE
BEGIN
    PRINT 'Stored procedure does not exist.';
END
GO
