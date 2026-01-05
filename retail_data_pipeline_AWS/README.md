
# Retail Data ETL Pipeline on AWS (Batch Processing)

This project demonstrates an automated, serverless batch ETL pipeline on AWS for processing raw retail data. It is designed for beginners in cloud computing and data engineering, showing how to integrate core AWS services to move data from raw storage to curated datasets, ready for analysis.

## Project Overview

The pipeline ingests raw retail datasets uploaded to Amazon S3 and automates their processing using AWS serverless services. The main goal is to extract, transform, and load (ETL) retail data efficiently while enabling real-time notifications and easy querying of curated data.

Key features include:

Batch processing of raw retail data stored in S3
Event-driven pipeline triggered by AWS Lambda
ETL transformations using AWS Glue
Event notifications via Amazon EventBridge and SNS
Querying curated data using AWS Athena
By the end of this project, users will understand how to build a fully automated ETL workflow for retail datasets in a serverless AWS environment.

## Architecture & Workflow

Data Ingestion: Upload raw retail files (CSV) to an S3 bucket.
Triggering the Pipeline: An AWS Lambda function detects new files in S3 and initiates the ETL process.
Data Transformation: AWS Glue jobs curate the raw retail data.
Event Notifications: Amazon EventBridge tracks pipeline events and routes them to SNS, sending real-time notifications (email alerts) when jobs complete.
Data Querying: Curated datasets are stored back in S3 and can be queried using AWS Athena for analytics and reporting.

## Pipeline Design

![Retail pipeline design](retail_pipeline_design.png)

## Technologies Used

Amazon S3 – Storage for raw and curated datasets
AWS Lambda – Event-driven function to trigger ETL jobs
AWS Glue – Serverless ETL service for data transformation
Amazon EventBridge & Amazon SNS – Notifications for monitoring pipeline events
AWS Athena – Querying curated datasets
