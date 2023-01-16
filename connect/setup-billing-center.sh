#!/bin/bash

ENV="dev"
SOURCE_TYPE="billing"

# kafka properties
CONNECT_SERVER_URL="http://localhost:8083"

# source S3 properties
S3_BUCKET_URI="/s3/billing-center/"
S3_ACCESS_KEY=""
S3_SECRET_KEY=""

# sink database properties
DB_URL="jdbc:postgresql://postgres:5432/cda"
DB_USER="kafka-connect-user"
DB_PASS="K@fk@Conn3ct!"
DB_SCHEMA="public"

printf 'Waiting until connect server REST API is ready to accept requests'
until $(curl --output /dev/null --silent --head --fail ${CONNECT_SERVER_URL}/connectors); do
    printf '.'
    sleep 3
done
echo ""
echo "Connect server REST API is ready to accept requests"

#echo "Creating topic ${ENV}.${SOURCE_TYPE}.table.changes..."
#docker exec -it broker /bin/bash -c "kafka-topics --bootstrap-server localhost:9092 --create --topic ${ENV}.${SOURCE_TYPE}.table.changes --partitions 1 --replication-factor 1"
#echo "Successfully created topic ${ENV}.${SOURCE_TYPE}.table.changes"
#echo ''

POST_DATA=$(cat <<EOF
{
  "name": "${ENV}-cda-${SOURCE_TYPE}",
  "config": {
    "connector.class": "com.mycompany.kafka.connect.cda.source.CdaSourceConnector",
    "tasks.max": "1",
    "poll.interval.ms": "3000",
    "poll.max.records": "500",
    "s3a.uri": "${S3_BUCKET_URI}",
    "fs.s3a.access.key": "${S3_ACCESS_KEY}",
    "fs.s3a.secret.key": "${S3_SECRET_KEY}",
    "table.whitelist": "",
    "table.blacklist": "",
    "topic": "${ENV}.raw.cda.${SOURCE_TYPE}.all",
    "broker.url": "kafka1.mycompany.com:29092",
    "broker.jaas.user": "",
    "broker.jaas.password": "",
    "consumer.group.id": "${ENV}-cda-${SOURCE_TYPE}",
    "table.notifier.topic": "${ENV}.cda.${SOURCE_TYPE}.table.changes",
    "manifest.notify.interval.ms": "5000",
    "manifest.listen.interval.ms": "10000",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url": "http://schema1.mycompany.com:8081",
    "key.converter.key.subject.name.strategy": "io.confluent.kafka.serializers.subject.RecordNameStrategy",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url": "http://schema1.mycompany.com:8081",
    "value.converter.value.subject.name.strategy": "io.confluent.kafka.serializers.subject.RecordNameStrategy",
    "transforms": "ValueToKey,SetSchemaName,Flatten",
    "transforms.ValueToKey.type": "org.apache.kafka.connect.transforms.ValueToKey",
    "transforms.ValueToKey.fields": "id",
    "transforms.SetSchemaName.type": "com.mycompany.kafka.connect.cda.source.transform.SetSchemaName",
    "transforms.SetSchemaName.schema.namespace": "${ENV}.raw.cda.",
    "transforms.Flatten.type": "org.apache.kafka.connect.transforms.Flatten\$Value",
    "transforms.Flatten.delimiter": "_"
  }
}
EOF
)

#echo "$POST_DATA"
#echo ''
#curl -k -H "Accept: application/json" -H "Content-Type: application/json" -X POST --data "$POST_DATA" $CONNECT_SERVER_URL/connectors
#echo ''

POST_DATA=$(cat <<EOF
{
  "name": "${ENV}-postgres-${SOURCE_TYPE}",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
    "tasks.max": "1",
    "connection.url": "${DB_URL}",
    "connection.user": "${DB_USER}",
    "connection.password": "${DB_PASS}",
    "topics.regex": "${ENV}\\\\.raw\\\\.cda\\\\.${SOURCE_TYPE}\\\\.all",
    "table.name.format": "\${topic}",
    "auto.create": "true",
    "auto.evolve": "true",
    "pk.mode": "record_key",
    "insert.mode": "upsert",
    "delete.enabled": "true",
    "errors.tolerance": "all",
    "errors.deadletterqueue.topic.name": "${ENV}.postgres.${SOURCE_TYPE}.dlq",
    "errors.deadletterqueue.topic.replication.factor": 1,
    "errors.deadletterqueue.context.headers.enable": true,
    "errors.retry.delay.max.ms": 10000,
    "errors.retry.timeout": 30000,
    "errors.log.enable": "true",
    "errors.log.include.messages": "true",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url": "http://schema1.mycompany.com:8081",
    "key.converter.key.subject.name.strategy": "io.confluent.kafka.serializers.subject.RecordNameStrategy",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url": "http://schema1.mycompany.com:8081",
    "value.converter.value.subject.name.strategy": "io.confluent.kafka.serializers.subject.RecordNameStrategy",
    "transforms": "RenameTopic",
    "transforms.RenameTopic.type": "com.mycompany.kafka.connect.cda.source.transform.SetTopicNameFromRecord",
    "transforms.RenameTopic.topic.prefix": "${DB_SCHEMA}."
  }
}
EOF
)
echo "$POST_DATA"
echo ''
curl -k -H "Accept: application/json" -H "Content-Type: application/json" -X POST --data "$POST_DATA" $CONNECT_SERVER_URL/connectors
echo ''
