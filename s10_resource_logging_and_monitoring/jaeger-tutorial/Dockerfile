FROM python:3.10-slim

RUN pip3 install jaeger-client requests
RUN mkdir /app
COPY app.py /app/

CMD ["python3", "/app/app.py"]