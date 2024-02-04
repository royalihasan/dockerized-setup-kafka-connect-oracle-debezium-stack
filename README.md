# Kafka Connect with Oracle Database Using Debezium

> Note:

## Repository Branches Overview

### 1. Demo Record Branch

The first branch in the Oracle-KI repository is dedicated to the demonstration record. Within this branch, the Debezium
connector version 1.9 has been utilized. Notably, the integration involves implicit Oracle plugging and encompasses
various additional functionalities. The payload associated with this branch provides a comprehensive overview of the
implemented features.

### 2. Upgraded Features Branch

The second branch focuses on upgraded features, incorporating the latest version of the Debezium connector and the
inclusion of the Kowl UI. In this branch, Oracle is not implicitly installed; instead, only the addition of the OJBC
driver is required. The setup includes multiple tables, and the payload details the specific configurations for
seamless integration.


---
## 1. Steps to Pull Oracle Database Enterprise(_21C_) Image

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

---

## 2. Prepare Database for CDC

**Step:1. Create recovery area folder**

_/opt/oracle/oradata/recovery_area_
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

**Step:2 Setup Logminer**

Run following script from Oracle docker container
https://raw.githubusercontent.com/royalihasan/dockerized-setup-kafka-connect-oracle-debezium-stack/master/src/main/resources/01_db_setup_scripts/01_logminer-setup.sh

```
curl https://raw.githubusercontent.com/royalihasan/dockerized-setup-kafka-connect-oracle-debezium-stack/master/src/main/resources/01_db_setup_scripts/01_logminer-setup.sh | sh
```

**Step3: Create Sample database**

https://raw.githubusercontent.com/royalihasan/dockerized-setup-kafka-connect-oracle-debezium-stack/master/src/main/resources/01_db_setup_scripts/inventory.sql

```bash
curl https://raw.githubusercontent.com/royalihasan/dockerized-setup-kafka-connect-oracle-debezium-stack/master/src/main/resources/01_db_setup_scripts/inventory.sql | sqlplus debezium/dbz@//localhost:1521/orclpdb1
```

**Step4: Check the Table is Created Successfully**

note check the name of the tns service to give correct service name in sqlplsus command above

_a. Start sqlplus prompt_

```bash
docker exec -it oracle bash -c 'sleep 1; sqlplus Debezium/dbz@localhost:1521/orclpdb1'
```

_b. USE Select Statement on Tables we created_

```oracle
SELECT *
FROM CUSTOMERS;
```

## 2. Prepare Debizium Connect for CDC

**Step1: Install the Required Drivers**
> First you Need to access the bash terminal of Oracle

`Change the Directiry to : cd libs`

**Step2: Now do Some Curls or Pulling the Jars(Drivers)**

```bash
curl https://maven.xwiki.org/externals/com/oracle/jdbc/ojdbc8/12.2.0.1/ojdbc8-12.2.0.1.jar -o ojdbc8-12.2.0.1.jar
curl https://repo1.maven.org/maven2/com/thoughtworks/xstream/xstream/1.3.1/xstream-1.3.1.jar -o xstream-1.3.1.jar
curl https://repo1.maven.org/maven2/com/oracle/database/xml/xdb/21.6.0.0/xdb-21.6.0.0.jar -o xdb-21.6.0.0.jar
```

**Step2: Setup the Instant Client Tool**
> Instant Client is used to Connect to Talk with Oracle db and XStream Api

`Change the Directory to : cd /kafka/external_libs`

_Now pull the Instant Client by doing Curl_

```bash
curl "https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basiclite-linux.x64-19.6.0.0.0dbru.zip" -O /tmp/ic.zip
unzip instantclient-basiclite-linux.x64-19.6.0.0.0dbru.zip
```

**Step3: Setup the Debizium JDBC Sink Plugins for Postgres**

`Change the Directory to : cd connect`

_Now pull the Plugins by doing Curl_
> Note: This is a tar file you can use tar `xvfz <file_name>` to extract it.

```shell
curl https://repo1.maven.org/maven2/io/debezium/debezium-connector-jdbc/2.5.0.Final/debezium-connector-jdbc-2.5.0.Final-plugin.tar.gz -O /tmp/ic.zip
tar xvfz  debezium-connector-jdbc-2.5.0.Final-plugin.tar.gz
```

**Step4:Now Restart the Debizium Connector**
> _Note: Use Docker to Restart the connector Service_

Hurrah all Configration all Complete

---

## 3. Create Connector for Testing

> Create a Oracle Source Connector

**Step1:**

`Generate a POST request on: ` _http://localhost:8083/connectors_

_By using this Payload_

```json
{
  "name": "oracle-customer-source-connector-00",
  "config": {
    "connector.class": "io.debezium.connector.oracle.OracleConnector",
    "database.hostname": "oracle",
    "database.port": "1521",
    "database.user": "c##dbzuser",
    "database.password": "dbz",
    "database.server.name": "test",
    "database.history.kafka.topic": "history",
    "database.dbname": "ORCLCDB",
    "database.connection.adapter": "LogMiner",
    "database.history.kafka.bootstrap.servers": "kafka:9092",
    "table.include.list": "DEBEZIUM.CUSTOMERS",
    "database.schema": "DEBEZIUM",
    "database.pdb.name": "ORCLPDB1",
    "snapshot.mode": "schema_only",
    "include.schema.changes": "true",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url": "http://schema-registry:8081",
    "value.converter.schema.registry.url": "http://schema-registry:8081"
  }
}
```

> Now check the Connector is Working Fine

`By Using this in you BASH`

```shell
curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
column -s : -t| sed 's/\"//g'| sort
```

`The Output Should be like this `

```text
source | oracle-customer-source-connector-00 | RUNNING | RUNNING | io.debezium.connector.oracle.OracleConnector
```

**Step2: Listen the Topic and Read Message messages**

`Access You Terminal and paste this command`

```shell
docker run --tty --network resources_default confluentinc/cp-kafkacat kafkacat -b kafka:9092 -C -s key=s -s value=avro -r http:/schema-registry:8081 -t test.DEBEZIUM.CUSTOMERS
```

> _Note: resources_default is the network , you can replace with you network name_

---

## 4.Verify the Changes (CDC)

**Step1: Access the BASH of Oracle DB**

```shell
docker exec -it oracle bash -c 'sleep 1; sqlplus Debezium/dbz@localhost:1521/orclpdb1'
```

**Step2: Enable Auto Commit by using this query**

```oracle
SET AUTOCOMMIT ON;
```

**Step3: Perform Some Changes**

`INSERT: `

```oracle
INSERT INTO CUSTOMERS
VALUES (NULL, 'Peter', 'Parker', 'peter.parker@marvel.com');
```

`UPDATE: `

```oracle
UPDATE CUSTOMERS
SET email = 'new_email@gmail.com'
WHERE id = 1041;
```

`DELETE: `

```oracle
DELETE
FROM CUSTOMERS
WHERE id = 1024;
```

_Now check the changes in the terminal where we are listening ou TOPIC_

---

## 5. Create a Postgres Connector as a Sink

> Note: Your Postgres should be UP and RUNNING

**Step1: Create a Sink request using this payload**

`POST on this URL : http://localhost:8083/connectors`

```json
{
  "name": "jdbc-postgres-sink-connector",
  "config": {
    "connector.class": "io.debezium.connector.jdbc.JdbcSinkConnector",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url": "http://schema-registry:8081",
    "tasks.max": "1",
    "connection.url": "jdbc:postgresql://postgres:5432/",
    "connection.username": "postgres",
    "connection.password": "postgres",
    "insert.mode": "upsert",
    "delete.enabled": "true",
    "auto.create": "true",
    "primary.key.mode": "record_key",
    "schema.evolution": "basic",
    "database.time_zone": "UTC",
    "topics": "test.DEBEZIUM.CUSTOMERS",
    "table.name.format": "customers"
  }
}
```

**Step2: Check the connector is Working Fine**

```shell
curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
column -s : -t| sed 's/\"//g'| sort
```

`The Output Should be like this `

```text
source | oracle-customer-source-connector-00 | RUNNING | RUNNING | io.debezium.connector.oracle.OracleConnector
sink   | jdbc-postgres-sink-connector        | RUNNING | RUNNING | io.debezium.connector.oracle.OracleConnector
```

> Now check the Changes in Postgres DB

`1. First You need to access the Postgres BASH and Login into it`

```shell
psql -U postgres
```

`2. Check the Tables in DB by using \td`

```sql
SELECT *
FROM customers;
```

> There will be a same Data which was in Oracle Db

_Hurrah , Congrats You have Done!_

---