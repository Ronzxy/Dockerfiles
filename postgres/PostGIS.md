# 创建PostGIS空间数据库

```sh

CONTAINER_NAME=postgres-master

docker exec -it ${CONTAINER_NAME} createdb -U postgres template-postgis
docker exec -it ${CONTAINER_NAME} psql -U postgres -f /usr/postgres/share/contrib/postgis-3.0/postgis.sql -d template-postgis
docker exec -it ${CONTAINER_NAME} psql -U postgres -f /usr/postgres/share/contrib/postgis-3.0/spatial_ref_sys.sql -d template-postgis

```
