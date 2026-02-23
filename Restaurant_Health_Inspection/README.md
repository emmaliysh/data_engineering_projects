# Restaurant Health Inspection Analysis (AWS EMR & Spark)
A data engineering project focused on processing and analyzing a large-scale public health dataset using Amazon EMR and Apache Spark. The goal was to transform raw inspection records into a query-optimized format to identify high-risk violations.

## Project Overview
This project demonstrates a complete ETL (Extract, Transform, Load) workflow in the cloud. It takes a raw dataset of 278,000+ restaurant inspection records, cleans the data, and aggregates specific health violations using distributed computing.

## Tech Stack
Language: Python (PySpark)

Compute: Amazon EMR (Elastic MapReduce)

Storage: Amazon S3

Database/Query: Amazon Athena

Networking: Amazon VPC, Security Groups

Format: Parquet (Snappy compression)

## Dataset
The project uses the Food Establishment Inspection Data.

Size: 278,000+ rows

Format: CSV

Key Columns: Name, Violation Type, Inspection Score, Inspection Date.

## Workflow
1. Infrastructure Setup
Configured an Amazon VPC with public subnets to host the cluster.

Launched an EMR Cluster (Release 6.x) with 1 Primary node and 2 Core nodes using m5.xlarge instances.

Managed secure access via EC2 Key Pairs and SSH.

2. Data Transformation (PySpark)
Ingested raw CSV data from an S3 bucket.

Cleaned and aliased columns for better query readability.

Created an in-memory temporary view to execute Spark SQL.

Filtered and aggregated "RED" (High-Risk) violations by restaurant name.

3. Storage & Querying
Wrote the transformed data back to S3 in Parquet format for better performance.

Connected Amazon Athena to the S3 output folder to allow for SQL-based ad-hoc analysis.

## Challenges Overcome
Service Quotas: Initially encountered vCPU limits for m5.xlarge instances. Resolved by adjusting the cluster size and instance types to fit within account limits.

Data Layout: Learned that tools like Athena require pointing to an S3 folder rather than a specific file to correctly read partitioned Parquet data.

Sample Output
The final transformation produces a table containing:
| name | total_red_violations |
| :--- | :--- |
| #807 TUTTA BELLA | 15 |
| SAMPLE RESTAURANT | 8 |

## How to Run
Upload emr.py and the dataset to your S3 bucket.

Launch an EMR cluster with Spark installed.

Add a "Step" to your cluster pointing to the emr.py script.

View the results in S3 or via Athena.