CREATE DATABASE IF NOT EXISTS retail_raw;

CREATE EXTERNAL TABLE retail_raw.transactions (
  transaction_id INT,
  transaction_date STRING,
  customer_id STRING,
  gender STRING,
  age INT,
  product_category STRING,
  quantity INT,
  price_per_unit DOUBLE,
  total_amount DOUBLE
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://learning-aws-etl-202613/load/'
TBLPROPERTIES (
  'skip.header.line.count' = '1'
);

SELECT
  transaction_id,
  CAST(transaction_date AS DATE) AS transaction_date,
  total_amount
FROM retail_raw.transactions
ORDER BY total_amount
LIMIT 10;