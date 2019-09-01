# 创建PostGIS空间数据库

CONTAINER_NAME=postgres_master

docker exec -it ${CONTAINER_NAME} createdb -U postgres template_postgis
docker exec -it ${CONTAINER_NAME} psql -U postgres -f /usr/postgres/share/contrib/postgis-2.5/postgis.sql -d template_postgis
docker exec -it ${CONTAINER_NAME} psql -U postgres -f /usr/postgres/share/contrib/postgis-2.5/spatial_ref_sys.sql -d template_postgis

