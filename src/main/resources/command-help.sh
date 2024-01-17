# Open Oracle bash
sudo docker exec -it oracle-db bash
# Run as sysdba
docker exec -it oracle-db sqlplus / as sysdba
# Run as system
docker exec -it oracle-db sqlplus system/oracle
# Run as user
docker exec -it oracle-db sqlplus user/password
# Run as user
docker exec -it oracle-db sqlplus user/password@localhost:1521/ORCLCDB.localdomain