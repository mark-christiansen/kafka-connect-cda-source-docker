# kafka-connect-cda-source-docker

This project is used to run the Guidewire CDA Source Connector in a local Docker environment for testing purposes. This
environment includes a single node Kafka cluster, Schema Registry, Prometheus, and Grafana. The Kafka Connect docker
image for the Guidewire CDA Source Connector needs to be built locally before running this project. 

## requirements

* Java 11 
* Docker

## setup

To set up this project make sure the base directory of this project is accessible to Docker through file sharing in your
local Docker setup (Settings -> Resources -> File Sharing). Then modify the `.env` file with your environment settings.
```
CONFLUENT_VERSION=7.3.1
DOMAIN=mycompany.com
ZK_HEAP=1G
BROKER_HEAP=3G
SCHEMA_HEAP=512M
CONNECT_HEAP=1G
CDA_CONNECT_IMAGE=mycompany/kafka-cda-source-connect:latest
```
Then run the `setup.sh` script in the base directory of this project. This script creates the `manifest.json` for Billing
and Policy Center S3 directories used by the CDA Source Connector. If these files aren't present, the CDA Source
Connector will fail when launched. The connector has the ability to pickup new files, directories and changes to the
`manifest.json` file.
```
% ./setup.sh

Create Billing Center manifest at "volumes/s3/billing-center/manifest.json"
Create Policy Center manifest at "volumes/s3/policy-center/manifest.json"
Starting Kafka environment
[+] Running 7/7
 ⠿ Network mycompany.com  Created                                                                                                                                                                                                             0.0s
 ⠿ Container zoo1         Healthy                                                                                                                                                                                                            21.2s
 ⠿ Container prometheus   Started                                                                                                                                                                                                             0.6s
 ⠿ Container grafana      Started                                                                                                                                                                                                             1.0s
 ⠿ Container kafka1       Healthy                                                                                                                                                                                                            34.1s
 ⠿ Container schema1      Healthy                                                                                                                                                                                                            44.9s
 ⠿ Container cda1         Started
```
When all containers are up you should see something like shown below when you execute `docker ps -a`. All containers
except prometheus and grafana (health checks not configured) should have a `(healthy)` status.
```
% docker ps -a

CONTAINER ID   IMAGE                                       COMMAND                  CREATED          STATUS                    PORTS                                                                NAMES
a7d971ce1c63   mycompany/kafka-cda-source-connect:latest   "/etc/confluent/dock…"   31 minutes ago   Up 30 minutes (healthy)   0.0.0.0:8083->8083/tcp, 0.0.0.0:9010-9011->9010-9011/tcp, 9092/tcp   cda1
d478bcd858b3   confluentinc/cp-schema-registry:7.3.1       "/etc/confluent/dock…"   31 minutes ago   Up 30 minutes (healthy)   0.0.0.0:8081->8081/tcp                                               schema1
02d52089d10c   grafana/grafana                             "/run.sh"                31 minutes ago   Up 30 minutes             0.0.0.0:3000->3000/tcp                                               grafana
d5f845148a1b   confluentinc/cp-server:7.3.1                "/etc/confluent/dock…"   31 minutes ago   Up 30 minutes (healthy)   0.0.0.0:9092->9092/tcp, 0.0.0.0:29092->29092/tcp                     kafka1
8d17fc634c23   confluentinc/cp-zookeeper:7.3.1             "/etc/confluent/dock…"   31 minutes ago   Up 30 minutes (healthy)   2888/tcp, 0.0.0.0:2181->2181/tcp, 3888/tcp                           zoo1
4f11a6a2a6a1   ubuntu/prometheus                           "/usr/bin/prometheus…"   31 minutes ago   Up 30 minutes             0.0.0.0:9090->9090/tcp                                               prometheus
```

## connector-setup

To start the Guidewire CDA Source Connector, change to the `connect` directory and execute either the setup scripts for 
either Billing Center or Policy Center (or both). Below is an example of starting up the Billing Center connector.
```
% ./setup-billing-center.sh

Waiting until connect server REST API is ready to accept requests
Connect server REST API is ready to accept requests
{
  "name": "dev-cda-billing",
  "config": {
    "connector.class": "com.mycompany.kafka.connect.cda.source.CdaSourceConnector",
    "tasks.max": "1",
    "poll.interval.ms": "3000",
    "poll.max.records": "500",
    "s3a.uri": "/s3/billing-center/",
    "fs.s3a.access.key": "",
    "fs.s3a.secret.key": "",
    "table.whitelist": "",
    "table.blacklist": "",
    "topic": "dev.raw.cda.billing.all",
    "broker.url": "kafka1.mycompany.com:29092",
    "broker.jaas.user": "",
    "broker.jaas.password": "",
    "consumer.group.id": "dev-cda-billing",
    "table.notifier.topic": "dev.cda.billing.table.changes",
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
    "transforms.SetSchemaName.schema.namespace": "dev.raw.cda.",
    "transforms.Flatten.type": "org.apache.kafka.connect.transforms.Flatten$Value",
    "transforms.Flatten.delimiter": "_"
  }
}

{"name":"dev-cda-billing","config":{"connector.class":"com.mycompany.kafka.connect.cda.source.CdaSourceConnector","tasks.max":"1","poll.interval.ms":"3000","poll.max.records":"500","s3a.uri":"/s3/billing-center/","fs.s3a.access.key":"","fs.s3a.secret.key":"","table.whitelist":"","table.blacklist":"","topic":"dev.raw.cda.billing.all","broker.url":"kafka1.mycompany.com:29092","broker.jaas.user":"","broker.jaas.password":"","consumer.group.id":"dev-cda-billing","table.notifier.topic":"dev.cda.billing.table.changes","manifest.notify.interval.ms":"5000","manifest.listen.interval.ms":"10000","key.converter":"io.confluent.connect.avro.AvroConverter","key.converter.schema.registry.url":"http://schema1.mycompany.com:8081","key.converter.key.subject.name.strategy":"io.confluent.kafka.serializers.subject.RecordNameStrategy","value.converter":"io.confluent.connect.avro.AvroConverter","value.converter.schema.registry.url":"http://schema1.mycompany.com:8081","value.converter.value.subject.name.strategy":"io.confluent.kafka.serializers.subject.RecordNameStrategy","transforms":"ValueToKey,SetSchemaName,Flatten","transforms.ValueToKey.type":"org.apache.kafka.connect.transforms.ValueToKey","transforms.ValueToKey.fields":"id","transforms.SetSchemaName.type":"com.mycompany.kafka.connect.cda.source.transform.SetSchemaName","transforms.SetSchemaName.schema.namespace":"dev.raw.cda.","transforms.Flatten.type":"org.apache.kafka.connect.transforms.Flatten$Value","transforms.Flatten.delimiter":"_","name":"dev-cda-billing"},"tasks":[],"type":"source"}
```
Looking at the CDA Source Connect logs (container for CDA Source Kafka Connect worker named `cda1` in `docker-compose.yml`),
we should see a message that the connector task started successfully.
```
% docker logs cda1 -f
...
[2023-01-16 19:39:03,046] INFO Guidewire CDA Source Task 0 started. (com.mycompany.kafka.connect.cda.source.CdaSourceTask)
```
It isn't doing anything because there isn't any data in the Billing Center S3 directory yet (`volumes/s3/billing-center`).
To generate that data, use the application contained within the Parquet converter library used by the CDA Source Connector.
This program not only generates data for different timestamps, it updates the `volumes/s3/billing-center/manifest.json`
on the fly so that the connector starts to read in the data and send it to Kafka as it is generated (much like what happens
in a production setting). When you check the CDA Source Connect logs again you should see messages that a new table was
found (in this case `bc_account`), a message indicating the starting timestamp folder and record number (both `-1` when
the connector hasn't read any messages in previously), and then subsequent messages that the task is consuming records.
```
% docker logs cda1 -f
...
[2023-01-16 19:39:03,046] INFO Guidewire CDA Source Task 0 started. (com.mycompany.kafka.connect.cda.source.CdaSourceTask)
[2023-01-16 19:46:56,729] INFO Task 0 notified task 0 of new table bc_account (com.mycompany.kafka.connect.cda.source.state.TableNotifier)
[2023-01-16 19:47:02,553] INFO Task 0 table listener adding new table bc_account (com.mycompany.kafka.connect.cda.source.state.TableListener)
[2023-01-16 19:47:02,734] INFO Starting table bc_account at timestamp -1, file all and record -1 (com.mycompany.kafka.connect.cda.source.state.TableStateManager)
[2023-01-16 19:47:04,166] INFO Task 0 consumed 300 records (com.mycompany.kafka.connect.cda.source.CdaSourceTask)
[2023-01-16 19:47:08,951] INFO Task 0 consumed 100 records (com.mycompany.kafka.connect.cda.source.CdaSourceTask)
[2023-01-16 19:47:14,964] INFO Task 0 consumed 100 records (com.mycompany.kafka.connect.cda.source.CdaSourceTask)
```
The data generated by the program in the Parquet converter library is mostly random and doesn't represent what real data
will look like for the various tables, but it is at least some data that will allow the connector to operate as intended.

## jmx-metrics

To see the custom JMX metrics of the CDA source connector, open up JConsole (comes with Java installation) by executing
the command below.
```
jconsole
```
When the JConsole window comes up, the "New Connection" dialog should be showing. Select the "Remote Process" radio
selection and type `locahhost:9010` in the text box below the "Remote Process" label. You will see a pop-up that says
"Secure connection failed. Retry insecurely?". Click the "Insecure connection" button. You should have connected now, so
select the "MBeans" menu. On the left-hand directory window you should see folders for `mycompany.cda.kafka.connect` as 
well as `kafka.connect`. The `mycompany.cda.kafka.connect` folder contains the custom metrics for the CDA Source
Connector and the `kafka.connect` folder contains the general metrics for the Kafka Connect workers.

## jmx-exporter-metrics

To see the metrics exposed by the [JMX Exporter](https://github.com/prometheus/jmx_exporter) running in the Kafka Connect 
worker container, open up an Internet browser and go to `http://localhost:9011/metrics`. You should see something like 
this in the browser window.
```
# HELP kafka_connect_source_task_metrics_source_record_active_count_avg The average number of records that have been produced by this task but not yet completely written to Kafka. (kafka.connect<type=source-task-metrics, connector=dev-cda-billing, task=0><>source-record-active-count-avg)
# TYPE kafka_connect_source_task_metrics_source_record_active_count_avg untyped
kafka_connect_source_task_metrics_source_record_active_count_avg{connector="dev-cda-billing",task="0",} 0.0
# HELP kafka_consumer_consumer_node_metrics_outgoing_byte_rate The number of outgoing bytes per second (kafka.consumer<type=consumer-node-metrics, client-id=consumer-cda-connect-cluster-2, node-id=node--1><>outgoing-byte-rate)
# TYPE kafka_consumer_consumer_node_metrics_outgoing_byte_rate gauge
kafka_consumer_consumer_node_metrics_outgoing_byte_rate{client_id="consumer-cda-connect-cluster-2",node_id="node--1",client_type="consumer",} 0.0
kafka_consumer_consumer_node_metrics_outgoing_byte_rate{client_id="consumer-dev-cda-billing-0-4",node_id="node-2147483646",client_type="consumer",} 59.02764681477011
...
```
This is the results of REST endpoint for the [JMX Exporter](https://github.com/prometheus/jmx_exporter). It runs as a
Java agent which retrieves the current values of JMX metrics, transforms the data, and then exposes the data on its
REST endpoint. The metrics retrieved and the subsequent transformation of that data is defined in the JMX Exporter
configuration which for the Kafka Connect worker is defined in `jmx-exporter/kafka_connect.yml` in this project. If the
custom metrics have a different name than `mycompany.cda.kafka.connect` in your CDA Source Connector application, you
will need to modify this file to match your metric settings.

## prometheus-metrics

The Prometheus console can be viewed by opening up an Internet browser to `http://localhost:9090`. To verify it is
receiving metrics from the JMX Exporter try looking up one of the values you saw in the JMX Exporter REST response. For
example, you might type `mycompany_cda_connector_records_number` in the Prometheus search screen and hit the "Execute"
button to find the number of records processed by th CDA Source Connector. You should see at least one message come up
if the connector has processed messages.
```
mycompany_cda_connector_records_number{env="dev", hostname="cda1.mycompany.com", instance="cda1.mycompany.com:9011", job="kafka-connect", kafka_connect_cluster_id="cda-connect-cluster", record_type="bc_account"}
1000
```

## grafana-metrics

Grafana is accessed by opening up an Internet browser to `http://localhost:3000`. You should be able to see two dashboards,
`CDA Source Connector` and `Kafka Connect`, the later coming from [JMX Monitoring Stacks](https://github.com/confluentinc/jmx-monitoring-stacks).
If both have data, then Grafana is properly retrieving data from Prometheus.

## connector-teardown

To stop just the connector and leave the rest of the environment running, change to the `connect` directory and execute 
the Billing Center teardown script or the Policy Center teardown script.
```
% ./teardown-billing-center.sh
% ./teardown-policy-center.sh
```

## teardown

To stop the entire environment, taking down all containers and cleaning up all data, execute the `teardown.sh` script in
the base directory of this project. This will delete all the data you generated in `volumes/s3` as well.
```
% ./teardown.sh

Stopping Kafka environment
[+] Running 7/7
 ⠿ Container cda1         Removed                                                                                                                                                                                                             0.7s
 ⠿ Container grafana      Removed                                                                                                                                                                                                             0.2s
 ⠿ Container prometheus   Removed                                                                                                                                                                                                             0.1s
 ⠿ Container schema1      Removed                                                                                                                                                                                                             0.6s
 ⠿ Container kafka1       Removed                                                                                                                                                                                                            10.5s
 ⠿ Container zoo1         Removed                                                                                                                                                                                                             0.5s
 ⠿ Network mycompany.com  Removed                                                                                                                                                                                                             0.1s
Cleaning up volumes
```