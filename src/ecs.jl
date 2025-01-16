const CLUSTER_NAME = "ClusterTest"
const TASK_DEFINITION = "julia-publish"
const LOG_GROUP_NAME = "/ecs/julia-publish"
const REGION = "us-east-1"
const SUBNET_ID = "subnet-39095b11"
const SECURITY_GROUP_ID = "sg-4719b522"

function get_container_environment()
    DotEnv.load!()

    keys = [
        "GITHUB_REPOSITORY", "GITHUB_REFERENCE", "GITHUB_TOKEN", "DEVELOPMENT_STAGE",
        "OVERWRITE", "JULIA_VERSION", "VERSION_SUFFIX", "AWS_ACCESS_KEY_ID",
        "AWS_SECRET_ACCESS_KEY", "SLACK_BOT_USER_OAUTH_ACCESS_TOKEN",
    ]

    return [Dict("name" => key, "value" => ENV[key]) for key in keys if haskey(ENV, key)]
end

function start_ecs_task()
    CONTAINER_ENVIRONMENT = get_container_environment()
    response = Ecs.run_task(
        TASK_DEFINITION,
        Dict(
            "cluster" => CLUSTER_NAME,
            "launchType" => "FARGATE",
            "networkConfiguration" => Dict(
                "awsvpcConfiguration" => Dict(
                    "subnets" => [SUBNET_ID],
                    "securityGroups" => [SECURITY_GROUP_ID],
                    "assignPublicIp" => "ENABLED",
                ),
            ),
            "overrides" => Dict(
                "containerOverrides" => [Dict(
                    "name" => "julia_publish",
                    "environment" => CONTAINER_ENVIRONMENT,
                )],
            ),
        ),
    )
    task_arn = response["tasks"][1]["taskArn"]
    println("Task started: $task_arn")
    return task_arn
end

function stop_ecs_task(task_id, retries = 20, delay = 15)
    Ecs.stop_ecs_task(
        task_id,
        Dict(
            "cluster" => CLUSTER_NAME,
        ),
    )
    println("Stopping task $task_id...")
    for attempt in 1:retries
        response = Ecs.describe_tasks(
            [task_id],
            Dict(
                "cluster" => CLUSTER_NAME,
            ),
        )
        task_status = response["tasks"][1]["lastStatus"]
        if task_status in ["STOPPED", "DEACTIVATING", "DEPROVISIONING"]
            println("Task $task_id stopped successfully.")
            return true
        end
        sleep(delay)
    end
    println("Task $task_id did not stop within $retries retries.")
    return false
end

function get_ecs_task_status(task_id::AbstractString)
    try
        response = Ecs.describe_tasks([task_id], Dict("cluster" => CLUSTER_NAME))
        return response["tasks"][1]["lastStatus"]
    catch e
        @error "Error retrieving task status $e"
        exit(1)
    end
end

function get_ecs_task_exit_code(task_id::AbstractString)
    try
        response = Ecs.describe_tasks([task_id], Dict("cluster" => CLUSTER_NAME))
        return response["tasks"][1]["containers"][1]["exitCode"]
    catch e
        @error "Error retrieving task exit code" exception = e
        exit(1)
    end
end

function get_ecs_log_stream(log_stream_name, next_token = nothing)
    try
        params = Dict(
            "logGroupName" => LOG_GROUP_NAME,
            "startFromHead" => true,
        )
        if next_token !== nothing
            params["nextToken"] = next_token
        end

        response = Cloudwatch_Logs.get_log_events(log_stream_name, params)
        for event in response["events"]
            println(event["message"])
        end

        return get(response, "nextForwardToken", nothing)
    catch e
        @error "Error retrieving logs" exception = e
        return nothing
    end
end

function start_ecs_task_and_watch()
    task_arn = start_ecs_task()
    task_id = split(task_arn, "/")[end]
    log_stream_name = "ecs/julia_publish/$task_id"
    next_token = nothing
    last_status = nothing

    try
        while true
            status = get_ecs_task_status(task_id)
            if status != last_status
                println("Task $task_id status: $status")
                last_status = status
            end
            if status == "STOPPED"
                exit_code = get_ecs_task_exit_code(task_id)
                println("Task $task_id finished with exit code $exit_code.")
                exit(exit_code)
            elseif status == "RUNNING"
                next_token = get_ecs_log_stream(log_stream_name, next_token)
            end
            sleep(1)
        end
    catch e
        @error "An error occurred. Stopping task..." exception = e
        stop_ecs_task(task_id)
    end

    return nothing
end
