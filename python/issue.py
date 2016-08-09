import asyncio
from aiokafka import AIOKafkaConsumer
from kafka.common import NoBrokersAvailable
import logging
import time

KAFKA_HOST = 'kafka'
KAFKA_PORT = 9092

KAFKA_BOOTSTRAP = '{}:{}'.format(KAFKA_HOST, KAFKA_PORT)
KAFKA_GROUP = 'test'
KAFKA_TOPIC = 'test-topic'


log_level = logging.INFO
log_format = '[%(asctime)s] %(levelname)s [%(name)s]: %(message)s'
logging.basicConfig(level=logging.WARNING, format=log_format)
log = logging.getLogger('rtu')
log.setLevel(log_level)


async def is_port_open(loop, host, port):
    try:
        reader, writer = await asyncio.open_connection(host, port, loop=loop)
        writer.close()
        return True
    except OSError:
        return False


async def wait_until_port_is_open(loop, host, port):
    while not await is_port_open(loop, host, port):
        await asyncio.sleep(0.001, loop=loop)


async def connect(loop, topic, kwargs):
    consumer = AIOKafkaConsumer(topic, loop=loop, **kwargs)
    await consumer.start()
    return consumer


async def connect_with_retry(loop, topic, kwargs):
    while True:
        try:
            consumer = await connect(loop, topic, kwargs)
            break
        except NoBrokersAvailable:
            await asyncio.sleep(0.001, loop=loop)
            print('No brokers available. Retrying...')
    return consumer


async def consume(consumer):
    message = await consumer.getone()
    print(message.value)
    await consumer.commit()


print('Waiting until Kafka port is open...')
loop = asyncio.get_event_loop()
loop.run_until_complete(wait_until_port_is_open(loop, KAFKA_HOST, KAFKA_PORT))

print('Open. Connect right away...')
kwargs = {
    'bootstrap_servers': KAFKA_BOOTSTRAP,
    'group_id': KAFKA_GROUP,
    'enable_auto_commit': False
}
task = connect_with_retry(loop, KAFKA_TOPIC, kwargs)
consumer = loop.run_until_complete(task)

print('Connected! The bug did not occur. Waiting for incoming messages...')
loop.run_until_complete(consume(consumer))
