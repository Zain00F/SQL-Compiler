
CREATE TABLE [dbo].[DIAGNOSIS](
	[DIAGNOSIS_KEY'1] [int] NOT NULL,
	[DIAGNOSIS_NAME] [nvarchar](300) NOT NULL,
	[DIAGNOSIS_CATEGORY_KEY] [int] NULL
	)

IF NOT EXISTS ( 
    SELECT 1 FROM sys.columns
    WHERE Name = 'KEY1''S'
      AND Object_ID = Object_ID('FACT1')
)
BEGIN
		ALTER TABLE FACT1 
        ADD [KEY1'S] INT NULL;
END
GO

UPDATE FACT1
SET [KEY1'S] =
    CASE 
        WHEN KEY2 = 4 OR KEY3 IN (1,7) THEN 1
        WHEN KEY5 = 2 THEN 2
        ELSE 0
    END
WHERE [KEY1'S] IS NULL;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE Name = 'HASH2' 
      AND Object_ID = Object_ID('FACT_2')
)
BEGIN
    ALTER TABLE FACT_2 
    ADD HASH2 BIGINT NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE Name = 'DIAGNOSIS_KEY''1' 
      AND Object_ID = Object_ID('FACT_2')
)
BEGIN
    ALTER TABLE FACT_2 
    ADD [DIAGNOSIS_KEY'1] INT NULL;
END
GO


DECLARE @ErrorMessage         NVARCHAR(4000)          
DECLARE @ErrorState           INT          
DECLARE @ErrorSeverity        INT 

/* DROP CONSTARINTS */
declare @sql_drop_constarints nvarchar(max)
set @sql_drop_constarints = ''
