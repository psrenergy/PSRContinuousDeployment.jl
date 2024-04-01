function notify_slack_channel(configuration::Configuration, slack_token::AbstractString, channel::AbstractString)
    Log.info("NOTIFY: Notifying the Slack channel of code $channel")
    target = configuration.target
    version = configuration.version
    message = "Version $version has been published: https://psr-update-modules.psr-inc.com/$target/$version.zip"

    context = SlackContext(slack_token)
    SlackAPI.channel_message(context, channel, message)

    return nothing
end
