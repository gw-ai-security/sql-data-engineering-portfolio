-- 01 - DATABASE EXPLORATION
-- Inspect database objects and column metadata before analyzing business values.

USE DataWarehouse;
GO

-- Explore database objects.
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- Explore the customer dimension schema.
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'
  AND TABLE_NAME = 'dim_customers'
ORDER BY ORDINAL_POSITION;
