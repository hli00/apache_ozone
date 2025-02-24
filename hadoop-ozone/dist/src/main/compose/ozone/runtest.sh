docker-compose down --remove-orphans
docker volume rm ozone_postgresql_data

./test-iceberg.sh
