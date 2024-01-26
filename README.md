# Kafka Connect with Oracle Database Using Debezium

# Oracle Database Enterprise Edition Docker Image

This guide will walk you through the process of pulling the Oracle Database Express Edition Docker image from the Oracle
Container Registry.

## Prerequisites

Before you begin, ensure that you have Docker installed on your machine. If not, you can download and install Docker
from [https://www.docker.com/get-started](https://www.docker.com/get-started).

## Steps to Pull Oracle Database Express Enterprise Image

1. **Login to Oracle Container Registry:**

   Run the following command to log in to the Oracle Container Registry. You will be prompted to enter your Oracle Cloud
   credentials (username and password):

   ```bash
   docker login container-registry.oracle.com
   ```
2. **Pull Image:**

   Run the following command
   ```bash
   docker pull container-registry.oracle.com/database/enterprise:latest
   ```

## 2.Start Oracle

## Create recovery area folder

/opt/oracle/oradata/recovery_area
otherwise following error might be observerd

```
SQL> ORA-01261: Parameter db_recovery_file_dest destination string cannot be translated

ORA-01262: Stat failed on a file destination directory

Linux-x86_64 Error: 2: No such file or directory

SQL> Disconnected

The Oracle base remains unchanged with value /opt/oracle

#####################################

########### E R R O R ###############

DATABASE SETUP WAS NOT SUCCESSFUL!

Please check output for further info!

########### E R R O R ###############

#####################################
```

## Setup Logminer

Run following script from Oracle docker container
https://github.com/debezium/oracle-vagrant-box/blob/main/setup-logminer.sh

```
curl https://raw.githubusercontent.com/debezium/oracle-vagrant-box/main/setup-logminer.sh | sh
```

## Create Sample database

https://github.com/debezium/debezium-examples/blob/main/tutorial/debezium-with-oracle-jdbc/init/inventory.sql

```
curl https://raw.githubusercontent.com/debezium/debezium-examples/main/tutorial/debezium-with-oracle-jdbc/init/inventory.sql | sqlplus debezium/dbz@//localhost:1521/orclpdb1
```

note check the name of the tns service to give correct service name in sqlplsus command above

Start sqlplus prompt

```
docker exec -it oracle bash -c 'sleep 1; sqlplus Debezium/dbz@localhost:1521/orclpdb1'
```

## Check Kafka Connect

```bash
echo -e "\n\n=============\nWaiting for Kafka Connect to start listening on localhost ⏳\n=============\n"
while [ $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) -ne 200 ] ; do
echo -e "\t" $(date) " Kafka Connect listener HTTP state: " $(curl -s -o /dev/null -w
%{http_code} http://localhost:8083/connectors) " (waiting for 200)"
sleep 5
done
echo -e $(date) "\n\n--------------\n\o/ Kafka Connect is ready! Listener HTTP state: " $(curl -s -o /dev/null -w
%{http_code} http://localhost:8083/connectors) "\n--------------\n"
 ```

### Add the ojdbc8 driver in Debizium Connect

```bash
echo First access the connect bash terminal
cd libs
# curl the driver
curl https://maven.xwiki.org/externals/com/oracle/jdbc/ojdbc8/12.2.0.1/ojdbc8-12.2.0.1.jar -o ojdbc8-12.2.0.1.jar
```

### Creat your First Connector

    - Post : http://localhost:8083/connectors

```json

{
  "name": "customer-table-0",
  "config": {
    "connector.class": "io.debezium.connector.oracle.OracleConnector",
    "database.hostname": "oracle",
    "database.port": "1521",
    "database.user": "c##dbzuser",
    "database.password": "dbz",
    "database.server.name": "c0",
    "database.dbname": "ORCLCDB",
    "database.connection.adapter": "LogMiner",
    "time.precision.mode": "connect",
    "database.history.kafka.bootstrap.servers": "kafka:9092",
    "database.history.kafka.topic": "customer-1",
    "table.include.list": "DEBEZIUM.CUSTOMERS",
    "database.schema": "DEBEZIUM",
    "database.pdb.name": "ORCLPDB1",
    "include.schema.changes": "true",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url": "http://schema-registry:8081",
    "value.converter.schema.registry.url": "http://schema-registry:8081"
  }
}
```

### Check Data or Tail the kafka topic and see if it's listening to debezium oracle changes

```bash
docker run --tty --network <your network name> confluentinc/cp-kafkacat kafkacat -b kafka:9092 -C -s key=s -s value=avro -r http:/schema-registry:8081 -t < you topic name>
```