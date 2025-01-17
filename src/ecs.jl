const CLUSTER_NAME = "ClusterTest"

function start_ecs_task(;
    configuration::Configuration,
    github_sha::AbstractString,
    overwrite::Bool,
)
    version_suffix = if isempty(configuration.version.prerelease)
        ""
    else
        string(configuration.version.prerelease[2])
    end

    environment = [
        # environment variables
        Dict("name" => "AWS_ACCESS_KEY_ID", "value" => ENV["AWS_ACCESS_KEY_ID"]),
        Dict("name" => "AWS_SECRET_ACCESS_KEY", "value" => ENV["AWS_SECRET_ACCESS_KEY"]),
        Dict("name" => "PERSONAL_ACCESS_TOKEN", "value" => ENV["PERSONAL_ACCESS_TOKEN"]),
        Dict("name" => "SLACK_BOT_USER_OAUTH_ACCESS_TOKEN", "value" => ENV["SLACK_BOT_USER_OAUTH_ACCESS_TOKEN"]),
        # configuration
        Dict("name" => "DEVELOPMENT_STAGE", "value" => string(configuration.development_stage)),
        Dict("name" => "GITHUB_REPOSITORY", "value" => "psrenergy/$(configuration.target).jl"),
        Dict("name" => "GITHUB_SHA", "value" => github_sha),
        Dict("name" => "JULIA_VERSION", "value" => string(VERSION)),
        Dict("name" => "OVERWRITE", "value" => string(overwrite)),
        Dict("name" => "VERSION_SUFFIX", "value" => version_suffix),
    ]

    response = Ecs.run_task(
        "julia-publish",
        Dict(
            "cluster" => CLUSTER_NAME,
            "launchType" => "FARGATE",
            "networkConfiguration" => Dict(
                "awsvpcConfiguration" => Dict(
                    "subnets" => ["subnet-39095b11"],
                    "securityGroups" => ["sg-4719b522"],
                    "assignPublicIp" => "ENABLED",
                ),
            ),
            "overrides" => Dict(
                "containerOverrides" => [Dict(
                    "name" => "julia_publish",
                    "environment" => environment,
                )],
            ),
        ),
    )
    task_arn = response["tasks"][1]["taskArn"]
    Log.info("ECS: Task started: $task_arn")
    return task_arn
end

function stop_ecs_task(task_id::AbstractString, retries::Integer = 20, delay::Integer = 15)
    Log.info("ECS: Stopping task $task_id...")
    Ecs.stop_ecs_task(
        task_id,
        Dict(
            "cluster" => CLUSTER_NAME,
        ),
    )

    for _ in 1:retries
        response = Ecs.describe_tasks(
            [task_id],
            Dict(
                "cluster" => CLUSTER_NAME,
            ),
        )
        task_status = response["tasks"][1]["lastStatus"]
        if task_status in ["STOPPED", "DEACTIVATING", "DEPROVISIONING"]
            Log.info("ECS: Task $task_id stopped successfully")
            return true
        end
        sleep(delay)
    end
    Log.info("ECS: Task $task_id did not stop within $retries retries")
    return false
end

function get_ecs_task_status(task_id::AbstractString)
    try
        response = Ecs.describe_tasks([task_id], Dict("cluster" => CLUSTER_NAME))
        return response["tasks"][1]["lastStatus"]
    catch e
        Log.fatal_error("ECS: Error retrieving task status ($e)")
    end
end

function get_ecs_task_exit_code(task_id::AbstractString)
    try
        response = Ecs.describe_tasks([task_id], Dict("cluster" => CLUSTER_NAME))
        return response["tasks"][1]["containers"][1]["exitCode"]
    catch e
        Log.fatal_error("ECS: Error retrieving task exit code ($e)")
    end
end

function get_ecs_log_stream(log_stream_name::AbstractString, next_token::Union{AbstractString, Nothing} = nothing)
    try
        params = Dict(
            "logGroupName" => "/ecs/julia-publish",
            "startFromHead" => true,
        )
        if next_token !== nothing
            params["nextToken"] = next_token
        end

        response = Cloudwatch_Logs.get_log_events(log_stream_name, params)
        for event in response["events"]
            Log.info(event["message"])
        end

        return get(response, "nextForwardToken", nothing)
    catch e
        Log.fatal_error("ECS: Error retrieving logs ($e)")
        return nothing
    end
end

function start_ecs_task_and_watch(;
    configuration::Configuration,
    github_sha::AbstractString,
    overwrite::Bool = false,
)
    task_arn = start_ecs_task(
        configuration = configuration,
        github_sha = github_sha,
        overwrite = overwrite,
    )
    task_id = split(task_arn, "/")[end]

    next_token = nothing
    last_status = nothing

    try
        while true
            status = get_ecs_task_status(task_id)
            if status != last_status
                Log.info("ECS: Task $task_id status: $status")
                last_status = status
            end
            if status == "STOPPED"
                exit_code = get_ecs_task_exit_code(task_id)
                Log.info("ECS: Task $task_id finished with exit code $exit_code")
                exit(exit_code)
            elseif status == "RUNNING"
                next_token = get_ecs_log_stream("ecs/julia_publish/$task_id", next_token)
            end
            sleep(1)
        end
    catch e
        Log.error("ECS: An error occurred. Stopping task ($e)")
        stop_ecs_task(task_id)
    end

    return nothing
end
