import os
import time
import boto3
from dotenv import load_dotenv
from botocore.exceptions import ClientError

CLUSTER_NAME = "ClusterTest"
TASK_DEFINITION = "julia-publish"
LOG_GROUP_NAME = "/ecs/julia-publish"
REGION = "us-east-1"
SUBNET_ID = "subnet-39095b11"
SECURITY_GROUP_ID = "sg-4719b522"

load_dotenv()

CONTAINER_ENVIRONMENT = [
    {"name": key, "value": os.getenv(key)}
    for key in [
        "GITHUB_REPOSITORY",
        "GITHUB_REFERENCE",
        "GITHUB_TOKEN",
        "DEVELOPMENT_STAGE",
        "OVERWRITE",
        "JULIA_VERSION",
        "VERSION_SUFFIX",
        "AWS_ACCESS_KEY_ID",
        "AWS_SECRET_ACCESS_KEY",
        "SLACK_BOT_USER_OAUTH_ACCESS_TOKEN",
    ]
]

ecs_client = boto3.client("ecs", region_name=REGION)
logs_client = boto3.client("logs", region_name=REGION)


def start_task():
    """Starts a Fargate task and returns its ARN."""
    try:
        response = ecs_client.run_task(
            cluster=CLUSTER_NAME,
            taskDefinition=TASK_DEFINITION,
            launchType="FARGATE",
            networkConfiguration={
                "awsvpcConfiguration": {
                    "subnets": [SUBNET_ID],
                    "securityGroups": [SECURITY_GROUP_ID],
                    "assignPublicIp": "ENABLED",
                }
            },
            overrides={
                "containerOverrides": [
                    {"name": "julia_publish", "environment": CONTAINER_ENVIRONMENT}
                ]
            },
        )
        task_arn = response["tasks"][0]["taskArn"]
        print(f"Task started: {task_arn}")
        return task_arn
    except ClientError as e:
        print(f"Error starting task: {e}")
        exit(1)


def stop_task(task_id, retries=10, delay=5):
    print(f"Stopping task {task_id}...")
    try:
        ecs_client.stop_task(cluster=CLUSTER_NAME, task=task_id)
        for attempt in range(retries):
            response = ecs_client.describe_tasks(cluster=CLUSTER_NAME, tasks=[task_id])
            task_status = response["tasks"][0]["lastStatus"]
            print(f"Attempt {attempt + 1}/{retries}: Task status is {task_status}")
            if task_status in ["STOPPED", "DEACTIVATING"]:
                print(f"Task {task_id} stopped successfully.")
                return True
            time.sleep(delay)
        print(f"Task {task_id} did not stop within {retries} retries.")
        return False
    except ClientError as e:
        print(f"Error stopping task: {e}")
        return False


def get_task_status(task_id):
    try:
        response = ecs_client.describe_tasks(cluster=CLUSTER_NAME, tasks=[task_id])
        return response["tasks"][0]["lastStatus"]
    except ClientError as e:
        print(f"Error retrieving task status: {e}")
        exit(1)


def get_task_exit_code(task_id):
    try:
        response = ecs_client.describe_tasks(cluster=CLUSTER_NAME, tasks=[task_id])
        return response["tasks"][0]["containers"][0]["exitCode"]
    except ClientError as e:
        print(f"Error retrieving task exit code: {e}")
        exit(1)


def stream_logs(log_stream_name, next_token=None):
    try:
        log_params = {
            "logGroupName": LOG_GROUP_NAME,
            "logStreamName": log_stream_name,
            "startFromHead": True,
        }
        if next_token:
            log_params["nextToken"] = next_token

        response = logs_client.get_log_events(**log_params)
        for event in response["events"]:
            print(event["message"])

        return response.get("nextForwardToken")
    except ClientError as e:
        print(f"Error retrieving logs: {e}")


def main():
    task_arn = start_task()
    task_id = task_arn.split("/")[-1]
    log_stream_name = f"ecs/julia_publish/{task_id}"
    next_token = None

    try:
        while True:
            status = get_task_status(task_id)
            print(f"Task {task_id} status: {status}")
            if status == "STOPPED":
                exit_code = get_task_exit_code(task_id)
                print(f"Task {task_id} finished with exit code {exit_code}.")
                exit(exit_code)
            elif status == "RUNNING":
                next_token = stream_logs(log_stream_name, next_token)
            time.sleep(1)
    except:
        print("An error occurred. Stopping task...")
        stop_task(task_id)


if __name__ == "__main__":
    main()
