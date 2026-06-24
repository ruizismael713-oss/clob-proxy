FROM python:3.11-slim

RUN apt-get update && apt-get install -y tor && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY server.py .
COPY torrc /etc/tor/torrc

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 8080
CMD ["./entrypoint.sh"]
