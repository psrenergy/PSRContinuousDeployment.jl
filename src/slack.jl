function notify_slack_channel(configuration::Configuration, slack_token::AbstractString, channel::AbstractString)
    target = configuration.target
    version = configuration.version
    message = "Version $version has been published: https://psr-update-modules.psr-inc.com/$target/$version.zip"

    context = SlackContext(slack_token)
    channel_message(context, channel, message)
    
    return nothing
end
