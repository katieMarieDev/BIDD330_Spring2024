USE [Crimson_Katharine]
GO


CREATE PROCEDURE [dbo].[sp_DimCountry]
AS
/***********
*Developer: KGuite
*Date: 04/16/2024
*Description: ETL Dim Country using Fact Unemployment
*
*
*
*
****************/

--Step 2: Drop Table
DROP TABLE IF EXISTS [dbo].[DimCountry]

--Step 3: Create Table with updated types
CREATE TABLE [dbo].[DimCountry]
(
	DimCountry_Key int IDENTITY (1,1) --future Surrogate Key
	,Country nvarchar(50)
)

--Step 4: Set all Countries to USA, since we're only working with states
INSERT INTO [dbo].[DimCountry]
SELECT DISTINCT --Please start with TOP 10 rows. This will speed up your attempts
	'USA'
FROM [Crimson_Katharine].[dbo].[FactUnemployment] FACT WITH (NOLOCK)
GO

-- Add a country column to FactUnemployment
ALTER TABLE [dbo].[FactUnemployment]
ADD Country nvarchar(50) DEFAULT 'USA' WITH VALUES;
GO

-- Only one Country, USA
SELECT * FROM dbo.DimCountry

-- Check Country column was added to FactUnemployment
SELECT * FROM [Crimson_Katharine].[dbo].[FactUnemployment]
