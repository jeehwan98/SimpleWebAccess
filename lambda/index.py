import boto3
import json
import os
import uuid
from datetime import datetime, timezone

s3 = boto3.client("s3")
S3_BUCKET = os.environ["S3_BUCKET"]

def handler(event, context):
    for record in event["Records"]:
        # parse the message body
        body = json.loads(record["body"])

        # builds an S3 key
        key = f"contacts/{datetime.now(timezone.utc).strftime('%Y/%m/%d')}/{uuid.uuid4()}.json"
        
        # write and save to S3 bucket
        s3.put_object(
            Bucket=S3_BUCKET,
            Key=key,
            Body=json.dumps(body),
            ContentType="application/json",
        )

    # tells SQS the message was processed successfully and can be deleted from the queue
    return {"statusCode": 200}
