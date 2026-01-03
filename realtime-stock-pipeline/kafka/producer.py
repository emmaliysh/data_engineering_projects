import json
import uuid

import time
import requests

from confluent_kafka import Producer

# set up variables for API

API_KEY="d3evmr9r01qh40fg7br0d3evmr9r01qh40fg7brg"
BASE_URL = "https://finnhub.io/api/v1/quote"
SYMBOLS = ["AAPL", "MSFT", "TSLA", "GOOGL", "AMZN"]


# https://finnhub.io/api/v1/quote?symbol=AAPL&token=d3evmr9r01qh40fg7br0d3evmr9r01qh40fg7brg

# Kafka configuration
conf = {'bootstrap.servers': 'localhost:9092'}
producer = Producer(conf)


#Retrive Data
def fetch_quote(symbol):
    url = f"{BASE_URL}?symbol={symbol}&token={API_KEY}"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        data["symbol"] = symbol
        data["fetched_at"] = int (time.time())
        return data
    
    except Exception as e:
        print(f"Error fetching {symbol}: {e}")
        return None
    

#Looping and Pushing to Stream
while True:
    for symbol in SYMBOLS:
        quote = fetch_quote(symbol)
        if quote:
            print(f"Producing: {quote}")

            # Single object
            producer.produce(
                topic='stock-quotes',
                key=str(quote.get('id', '')),
                value=json.dumps(quote).encode('utf-8'),
            )

    producer.poll(0)
    time.sleep(5)  # wait before next fetch


producer.flush()