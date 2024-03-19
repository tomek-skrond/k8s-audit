#COMMAND TO START TEST DB:
#docker run --rm --name test-postgres -e POSTGRES_PASSWORD=pass -e POSTGRES_DB=fruits -e POSTGRES_USER=finger -dp 5432:5432 postgres:13
#CREATE DUMMY USER:
#insert into account (username,password,created_at) values ('tomek','1234','2024-02-17');
#CONNECT TO DB:
#psql -h 127.0.0.1 -U finger ttregistr
#OR:
#docker exec -it test-postgres /bin/bash -c "psql -h 127.0.0.1 -U finger ttregistr"

### DEBUG CONTAINER: create docker-compose.yaml in src/ folder
# version: "3.0"

# services:
#   app:
#     build: .
#     restart: always
#     ports:
#       - "1323:1323"
#     environment:
#       POSTGRES_DB: fruits
#       POSTGRES_USER: user
#       POSTGRES_PASSWORD: pass
#       POSTGRES_HOST: postgres-db
#       SSLMODE: disable
#     depends_on:
#       - db
#   db:
#     image: postgres:14
#     container_name: postgres-db
#     ports:
#       - "5432:5432"
#     environment:
#       POSTGRES_DB: fruits
#       POSTGRES_USER: user
#       POSTGRES_PASSWORD: pass

