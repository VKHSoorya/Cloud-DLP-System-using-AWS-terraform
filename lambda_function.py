import boto3
import re
import os

s3 = boto3.client('s3')
sns_client = boto3.client('sns')

# Get values from environment variables (set via Terraform)
MAIN_BUCKET = os.environ['MAIN_BUCKET']
SECURE_BUCKET = os.environ['SECURE_BUCKET']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']


# Move file to secure bucket
def change_location(bucket, key):
    copy_source = {
        'Bucket': bucket,
        'Key': key
    }

    s3.copy_object(
        CopySource=copy_source,
        Bucket=SECURE_BUCKET,
        Key=key
    )

    print(f"{key} copied successfully")

    s3.delete_object(Bucket=bucket, Key=key)
    print(f"{key} deleted successfully")


# SNS alert
def sns_email_alert(key):
    response = sns_client.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=f'DLP alert triggered for file: {key}',
        Subject='DLP Alert - Sensitive Data Detected'
    )

    print("Message sent ID:", response['MessageId'])


# PII detection
def pii_checking(text):

    patterns = {
        "email": r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
        "pan": r'\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b',
        "phone": r'\+?\d{1,3}?[-.\s]?\(?\d{2,4}\)?[-.\s]?\d{6,10}\b',
        "aadhaar": r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}\b',
        "credit_card": r'\b(?:\d[ -]*?){13,16}\b',
        "ssn": r'\b\d{3}-\d{2}-\d{4}\b',
        "ip_address": r'\b(?:\d{1,3}\.){3}\d{1,3}\b'
    }

    for key, pattern in patterns.items():
        if re.search(pattern, text):
            print(f"{key} found")
            return True

    return False

def lambda_handler(event, context):

    for record in event['Records']:

        bucket_name = record['s3']['bucket']['name']
        file_key = record['s3']['object']['key']

        print(f"Processing file: {file_key}")

        # Get file content
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        text = response['Body'].read().decode(errors='ignore')

        # Check PII
        if pii_checking(text):
            change_location(bucket_name, file_key)
            sns_email_alert(file_key)
        else:
            print("No PII found")

    return {"status": "done"}