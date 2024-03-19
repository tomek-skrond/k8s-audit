#COMMAND TO START TEST DB:
#docker run --rm --name test-postgres -e POSTGRES_PASSWORD=pass -e POSTGRES_DB=fruits -e POSTGRES_USER=finger -dp 5432:5432 postgres:13
#CREATE DUMMY USER:
#insert into account (username,password,created_at) values ('tomek','1234','2024-02-17');
#CONNECT TO DB:
#psql -h 127.0.0.1 -U finger ttregistr
#OR:
#docker exec -it test-postgres /bin/bash -c "psql -h 127.0.0.1 -U finger ttregistr"

export POSTGRES_PASSWORD=pass
export POSTGRES_DB=fruits
export POSTGRES_USER=user
export POSTGRES_HOST=127.0.0.1
export SSLMODE="disable"
