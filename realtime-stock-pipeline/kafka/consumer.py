import json
import boto3
import time
from confluent_kafka import Consumer

#Minio Connection
s3 = boto3.client(
    "s3",
    endpoint_url="http://localhost:9002",
    aws_access_key_id="admin",
    aws_secret_access_key="password123"
)

bucket_name = "bronze-transactions"

# Ensure bucket exists (idempotent)
try:
    s3.head_bucket(Bucket=bucket_name)
    print(f"Bucket {bucket_name} already exists.")
except Exception:
    s3.create_bucket(Bucket=bucket_name)
    print(f"Created bucket {bucket_name}.")


# set up consumer
consumer_config = {
    "bootstrap.servers": "localhost:9092",
    "group.id": "consumer",
    "auto.offset.reset": "earliest"
}

consumer = Consumer(consumer_config)

consumer.subscribe(["stock-quotes"])

print("Consumer is running and subscribed to stock-quotes topic")


try:
    while True:
        msg = consumer.poll(1.0)
        if msg is None:
            continue
        if msg.error():
            print("Error:", msg.error())
            continue

        

        value = msg.value().decode("utf-8")
        record = json.loads(value)
        print(f"Received stock-quotes: {record}")


        symbol = record.get("symbol", "unknown")
        ts = record.get("fetched_at",int(time.time()))
        key = f"{symbol}/{ts}.json"


        s3.put_object(
            Bucket=bucket_name,
            Key=key,
            Body=json.dumps(record),
            ContentType="application/json"
        )
        print(f"Saved record for {symbol} = s3://{bucket_name}/{key}")





except KeyboardInterrupt:
    print("\n Stopping consumer")

finally:
    consumer.close()