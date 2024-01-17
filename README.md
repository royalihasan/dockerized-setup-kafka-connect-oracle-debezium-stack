# Kafka Connect with Oracle Database Using Debezium

# Oracle Database Express Edition Docker Image

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
   docker pull container-registry.oracle.com/database/express:latest
   ```