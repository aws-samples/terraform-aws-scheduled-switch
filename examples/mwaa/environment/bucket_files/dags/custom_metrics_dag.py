# Copyright © 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved. This AWS Content is provided subject to the terms of the AWS Customer Agreement available at http://aws.amazon.com/agreement or other written agreement between Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both."
# Source: https://docs.aws.amazon.com/mwaa/latest/userguide/samples-custom-metrics.html

import os
import socket
from datetime import datetime, timedelta

import boto3
import psutil
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago

default_args = {
    "owner": "foo",
    "retries": 4,
    "retry_delay": timedelta(minutes=5),
}


def publish_metric(client, name, value, cat, unit="None"):
    environment_name = os.getenv("AIRFLOW_ENV_NAME")
    value_number = float(value)
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    print("writing value", value_number, "to metric", name)
    response = client.put_metric_data(
        Namespace="MWAA-Custom",
        MetricData=[
            {
                "MetricName": name,
                "Dimensions": [
                    {"Name": "Environment", "Value": environment_name},
                    {"Name": "Category", "Value": cat},
                    {"Name": "Host", "Value": ip_address},
                ],
                "Timestamp": datetime.now(),
                "Value": value_number,
                "Unit": unit,
            },
        ],
    )
    print(response)
    return response


def python_fn(**kwargs):
    client = boto3.client("cloudwatch")

    cpu_stats = psutil.cpu_stats()
    print("cpu_stats", cpu_stats)

    virtual = psutil.virtual_memory()
    cpu_times_percent = psutil.cpu_times_percent(interval=0)

    publish_metric(
        client=client,
        name="virtual_memory_total",
        cat="virtual_memory",
        value=virtual.total,
        unit="Bytes",
    )
    publish_metric(
        client=client,
        name="virtual_memory_available",
        cat="virtual_memory",
        value=virtual.available,
        unit="Bytes",
    )
    publish_metric(
        client=client,
        name="virtual_memory_used",
        cat="virtual_memory",
        value=virtual.used,
        unit="Bytes",
    )
    publish_metric(
        client=client,
        name="virtual_memory_free",
        cat="virtual_memory",
        value=virtual.free,
        unit="Bytes",
    )
    publish_metric(
        client=client,
        name="virtual_memory_active",
        cat="virtual_memory",
        value=virtual.active,
        unit="Bytes",
    )
    publish_metric(
        client=client,
        name="virtual_memory_inactive",
        cat="virtual_memory",
        value=virtual.inactive,
        unit="Bytes",
    )
    publish_metric(
        client=client,
        name="virtual_memory_percent",
        cat="virtual_memory",
        value=virtual.percent,
        unit="Percent",
    )

    publish_metric(
        client=client,
        name="cpu_times_percent_user",
        cat="cpu_times_percent",
        value=cpu_times_percent.user,
        unit="Percent",
    )
    publish_metric(
        client=client,
        name="cpu_times_percent_system",
        cat="cpu_times_percent",
        value=cpu_times_percent.system,
        unit="Percent",
    )
    publish_metric(
        client=client,
        name="cpu_times_percent_idle",
        cat="cpu_times_percent",
        value=cpu_times_percent.idle,
        unit="Percent",
    )

    return "OK"


with DAG(
    dag_id=os.path.basename(__file__).replace(".py", ""),
    schedule_interval="*/5 * * * *",
    catchup=False,
    start_date=days_ago(1),
    default_args=default_args,
) as dag:
    t = PythonOperator(
        task_id="memory_test", python_callable=python_fn, provide_context=True
    )
