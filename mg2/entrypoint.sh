#!/bin/sh

UUID=$(uuidgen)
SEND_UUID=$(uuidgen)

sed -i -e 's/$PORT/'"$PORT"'/g' /app/conf.py
sed -i -e 's/$SEND_PORT/'"$SEND_PORT"'/g' /app/conf.py
sed -i -e 's/$RECV_PORT/'"$RECV_PORT"'/g' /app/conf.py

sed -i -e 's/$UUID/'"$UUID"'/g' /app/conf.py
sed -i -e 's/$SEND_UUID/'"$SEND_UUID"'/g' /app/conf.py

mkdir run
mkdir logs
mkdir tmp

m2sh load -config ./conf.py
m2sh servers -db ./config.sqlite
m2sh start -db ./config.sqlite -host localhost

tail -f ./logs/*.log
