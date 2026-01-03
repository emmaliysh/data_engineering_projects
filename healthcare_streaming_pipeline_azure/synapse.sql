-- ==============================
-- 1️⃣ CREATE MASTER KEY IF NOT EXISTS
-- ==============================
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'synapse-healthcare123';
END
GO

-- ==============================
-- 2️⃣ CREATE DATABASE SCOPED CREDENTIAL IF NOT EXISTS
-- ==============================
IF NOT EXISTS (SELECT * FROM sys.database_scoped_credentials WHERE name = 'storage_credential')
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL storage_credential
    WITH IDENTITY = 'Managed Identity';
END
GO

-- ==============================
-- 3️⃣ CREATE EXTERNAL DATA SOURCE IF NOT EXISTS
-- ==============================
IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'gold_data_source')
BEGIN
    CREATE EXTERNAL DATA SOURCE gold_data_source
    WITH (
        TYPE = HADOOP,
        LOCATION = 'abfss://gold@storageaccounthealthcare.dfs.core.windows.net/',
        CREDENTIAL = storage_credential
    );
END
GO

-- ==============================
-- 4️⃣ CREATE EXTERNAL FILE FORMAT IF NOT EXISTS
-- ==============================
IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'ParquetFileFormat')
BEGIN
    CREATE EXTERNAL FILE FORMAT ParquetFileFormat
    WITH (
        FORMAT_TYPE = PARQUET
    );
END
GO

-- ==============================
-- 5️⃣ CREATE EXTERNAL TABLES IF NOT EXISTS
-- ==============================
-- PATIENT DIMENSION
IF OBJECT_ID('dbo.dim_patient', 'U') IS NULL
BEGIN
    CREATE EXTERNAL TABLE dbo.dim_patient (
        patient_id VARCHAR(50),
        gender VARCHAR(10),
        age INT,
        effective_from DATETIME2,
        surrogate_key BIGINT,
        effective_to DATETIME2,
        is_current BIT
    )
    WITH (
        LOCATION = 'patient/',
        DATA_SOURCE = gold_data_source,
        FILE_FORMAT = ParquetFileFormat
    );
END
GO

-- DEPARTMENT DIMENSION
IF OBJECT_ID('dbo.dim_department', 'U') IS NULL
BEGIN
    CREATE EXTERNAL TABLE dbo.dim_department (
        surrogate_key BIGINT,
        department NVARCHAR(200),
        hospital_id INT
    )
    WITH (
        LOCATION = 'department/',
        DATA_SOURCE = gold_data_source,
        FILE_FORMAT = ParquetFileFormat
    );
END
GO

-- FACT TABLE
IF OBJECT_ID('dbo.fact_patient_flow', 'U') IS NULL
BEGIN
    CREATE EXTERNAL TABLE dbo.fact_patient_flow (
        fact_id BIGINT,
        patient_sk BIGINT,
        department_sk BIGINT,
        admission_time DATETIME2,
        discharge_time DATETIME2,
        admission_date DATE,
        length_of_stay_hours FLOAT,
        is_currently_admitted BIT,
        bed_id INT,
        event_ingestion_time DATETIME2
    )
    WITH (
        LOCATION = 'fact/',
        DATA_SOURCE = gold_data_source,
        FILE_FORMAT = ParquetFileFormat
    );
END
GO

-- ==============================
-- 6️⃣ SAMPLE QUERY
-- ==============================
SELECT TOP 100 * FROM dbo.fact_patient_flow;
