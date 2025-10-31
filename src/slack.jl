function notify_slack_channel(configuration::Configuration, slack_token::AbstractString, channel::AbstractString)
    Log.info("NOTIFY: Notifying the Slack channel of code $channel")
    target = configuration.target
    version = configuration.version
    message = "Version $version has been published: https://psr-update-modules.psr-inc.com/$target/$version.zip"

    context = SlackContext(slack_token)
    response = SlackAPI.channel_message(context, channel, message)
    if response.status != 200
        Log.warn("NOTIFY: Failed to notify the Slack channel of code $channel. Status: $(response.status)")
        return nothing
    end

    return nothing
end

function notify_slack_channel(; configuration::Configuration, slack_token::AbstractString, channel::AbstractString, url::AbstractString)
    target = configuration.target
    version = configuration.version
    message = "$target v$version has been published: $url"

    slack_channel_message(; channel, message, slack_token)
    return nothing
end

function slack_channel_message(; channel::AbstractString, message::AbstractString, slack_token::AbstractString = ENV["SLACK_BOT_USER_OAUTH_ACCESS_TOKEN"])
    Log.info("NOTIFY: Notifying the Slack channel of code $channel")

    context = SlackContext(slack_token)
    response = SlackAPI.channel_message(context, channel, message)
    if response.status != 200
        Log.warn("NOTIFY: Failed to notify the Slack channel of code $channel. Status: $(response.status)")
        return nothing
    end

    return nothing
end
