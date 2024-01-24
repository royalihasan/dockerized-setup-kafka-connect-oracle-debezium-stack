# Kafka Connect with Oracle Database Using Debezium

# Oracle Database Enterprise Edition Docker Image

This guide will walk you through the process of pulling the Oracle Database Express Edition Docker image from the Oracle
Container Registry.

## Prerequisites

Before you begin, ensure that you have Docker installed on your machine. If not, you can download and install Docker
from [https://www.docker.com/get-started](https://www.docker.com/get-started).

## Steps to Pull Oracle Database Express Edition Image

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

3. **Check Kafka Connect:**
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