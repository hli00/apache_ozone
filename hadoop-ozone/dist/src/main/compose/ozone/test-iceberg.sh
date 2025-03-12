#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#suite:integration

COMPOSE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export COMPOSE_DIR

export SECURITY_ENABLED=false
export OZONE_REPLICATION_FACTOR=3
# export COMPOSE_FILE=docker-compose.yaml:iceberg.yaml:trino.yaml
export COMPOSE_FILE=docker-compose.yaml:hive.yaml:trino.yaml

export KEEP_ENV_RUNNING=true

# shellcheck source=/dev/null
source "$COMPOSE_DIR/../testlib.sh"

start_docker_env 3

#export BUCKET=warehouse
#execute_command_in_container s3g ozone sh bucket create --layout OBJECT_STORE /s3v/${BUCKET}

# workaround for HDDS-11132 that affects 1.4.0
docker-compose exec om ozone sh volume create /volume1
docker-compose exec om ozone sh bucket create /volume1/bucket1
#docker-compose exec om ozone sh bucket create --layout LEGACY /volume1/bucket1

execute_command_in_container trino trino <<EOF
-- CREATE SCHEMA hive.test_schema WITH (location = 's3://warehouse/');
DROP TABLE IF EXISTS hive.test_schema.t0;
DROP SCHEMA IF EXISTS hive.test_schema;
CREATE SCHEMA hive.test_schema;
show CREATE SCHEMA hive.test_schema;
-- CREATE TABLE hive.test_schema.t0(name VARCHAR, id INT) with (format = 'PARQUET', location = 's3://warehouse/test_schema/t0');
-- CREATE TABLE hive.test_schema.t0(name VARCHAR, id INT) with (format = 'PARQUET', partitioned_by = ARRAY['id']);
CREATE TABLE hive.test_schema.t0(name VARCHAR, id INT) with (format = 'PARQUET', partitioned_by = ARRAY['id'], external_location = 'ofs://om/volume1/bucket1/');
show create table hive.test_schema.t0;
INSERT INTO hive.test_schema.t0 VALUES ('Test1', 10);
INSERT INTO hive.test_schema.t0 VALUES ('Test2', 20);
INSERT INTO hive.test_schema.t0 VALUES ('Test2', 30);
SELECT * FROM hive.test_schema.t0;
SELECT count(id) FROM hive.test_schema.t0 group by name;

-- CREATE SCHEMA iceberg.test_schema WITH (location = 's3://warehouse/');
-- show CREATE SCHEMA iceberg.test_schema;
-- DESCRIBE iceberg.nyc.taxis;
-- show create table iceberg.nyc.taxis;
-- INSERT INTO iceberg.nyc.taxis VALUES (2, 1000375, 7.2, 555, 'N');
-- SELECT * FROM iceberg.nyc.taxis;
-- CREATE TABLE iceberg.test_schema.t0(name VARCHAR, id INT) with (format = 'PARQUET', location = 's3://warehouse/test_schema/t0'); 
-- show create table iceberg.test_schema.t0;
-- INSERT INTO iceberg.test_schema.t0 VALUES ('Test1', 10);
-- INSERT INTO iceberg.test_schema.t0 VALUES ('Test2', 20);
-- INSERT INTO iceberg.test_schema.t0 VALUES ('Test2', 30);
-- SELECT * FROM iceberg.test_schema.t0;
-- SELECT count(id) FROM iceberg.test_schema.t0 group by name;
EOF

execute_robot_test scm -v BUCKET:${BUCKET} integration/iceberg.robot
