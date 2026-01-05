import json
import boto3

def lambda_handler(event, context):
    # TODO implement

    glue = boto3.client('glue')
    job_name = 'etl'

    try:
        response = glue.start_job_run(JobName=job_name)

        return {
            'statusCode': 200,
            'body': f"Job {job_name} started successfully. JobRunId: {response['JobRunId']}"
        
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': f"Error starting job {job_name}: {str(e)}"
        }

