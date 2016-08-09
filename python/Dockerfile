FROM alpine:3.3

RUN apk update && apk add python3 python3-dev linux-headers
RUN python3 -m ensurepip --upgrade
RUN pip3 install aiokafka==0.1.2
RUN mkdir /code

CMD python3 -u /code/issue.py
