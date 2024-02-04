# Kafka Connect with Oracle Database Using Debezium

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
```

**Step3:Now Restart the Debizium Connector**
> _Note: Use Docker to Restart the connector Service_

Hurrah, all Configurations Complete

---

## 3. Create Connector for Testing

> Note There are Multiple tables in `tables` dir

> Create a Oracle Source Connector

**Step1:**

`Generate a POST request on: ` _http://localhost:8083/connectors_

_By using this Payload_

Avro Based Connector

```json
{
  "name": "generic-inventory-connector",
  "config": {
    "connector.class": "io.debezium.connector.oracle.OracleConnector",
    "database.hostname": "oracle",
    "database.port": "1521",
    "database.user": "c##dbzuser",
    "database.password": "dbz",
    "database.dbname": "ORCLCDB",
    "topic.prefix": "oracle",
    "tasks.max": "1",
    "database.pdb.name": "ORCLPDB1",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes.inventory"
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
source | generic-inventory-connector | RUNNING | RUNNING | io.debezium.connector.oracle.OracleConnector
```

**Step2: Listen the Topic and Read Message messages**

`Access You Terminal and paste this command`
_For Avro Based Tailing_

```shell
docker run --tty --network resources_default confluentinc/cp-kafkacat kafkacat -b kafka:9092 -C -s key=s -s value=avro -r http:/schema-registry:8081 -t test.DEBEZIUM.CUSTOMERS
```

_For Json Based Tailing_

```shell
docker run --tty --network resources_default confluentinc/cp-kafkacat kafkacat -b kafka:9092 -C -f "%S: %s\n"  -t test1.DEBEZIUM.CUSTOMERS

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
> Note: include `topics` according to you specs

```json
{
  "name": "jdbc-sink-connector-generic",
  "config": {
    "connector.class": "io.debezium.connector.jdbc.JdbcSinkConnector",
    "tasks.max": "1",
    "connection.url": "jdbc:postgresql://postgres:5432/",
    "connection.username": "postgres",
    "connection.password": "postgres",
    "insert.mode": "upsert",
    "delete.enabled": "true",
    "primary.key.mode": "record_key",
    "schema.evolution": "basic",
    "database.time_zone": "UTC",
    "topics": "oracle.DEBEZIUM.PRODUCT_CATEGORIES, oracle.DEBEZIUM.PRODUCT_CATEGORY_MAPPING, oracle.DEBEZIUM.PRODUCT_REVIEWS, oracle.DEBEZIUM.PRODUCTS, oracle.DEBEZIUM.PRODUCTS_ON_HAND, oracle.DEBEZIUM.SHIPMENTS, oracle.DEBEZIUM.SUPPLIERS"
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
source | generic-inventory-connector | RUNNING | RUNNING | io.debezium.connector.oracle.OracleConnector
sink   | jdbc-sink-connector-generic | RUNNING | RUNNING | io.debezium.connector.oracle.OracleConnector
```

> Now check the Changes in Postgres DB

`1. First You need to access the Postgres BASH and Login into it`

```shell
psql -U postgres
```

`2. Check the Tables in DB by using \td`

```sql
SELECT *
FROM < table_name >;
```

> There will be a same Data which was in Oracle Db

_Hurrah , Congrats You have Done!_

---