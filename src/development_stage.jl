@enumx DevelopmentStage PreAlpha Alpha Beta ReleaseCandidate StableRelease

function to_version(development_stage::DevelopmentStage.T)
    if development_stage == DevelopmentStage.PreAlpha
        return "prealpha"
    elseif development_stage == DevelopmentStage.Alpha
        return "alpha"
    elseif development_stage == DevelopmentStage.Beta
        return "beta"
    elseif development_stage == DevelopmentStage.ReleaseCandidate
        return "rc"
    elseif development_stage == DevelopmentStage.StableRelease
        return ""
    else
        throw(ErrorException("Invalid development stage ($development_stage)"))
    end
end

function Base.string(development_stage::DevelopmentStage.T)
    if development_stage == DevelopmentStage.PreAlpha
        return "pre alpha"
    elseif development_stage == DevelopmentStage.Alpha
        return "alpha"
    elseif development_stage == DevelopmentStage.Beta
        return "beta"
    elseif development_stage == DevelopmentStage.ReleaseCandidate
        return "release candidate"
    elseif development_stage == DevelopmentStage.StableRelease
        return "stable release"
    else
        throw(ErrorException("Invalid development stage ($development_stage)"))
    end
end

function Base.parse(::Type{DevelopmentStage.T}, string::String)
    lowercase_string = lowercase(string)

    if lowercase_string == "pre alpha"
        return DevelopmentStage.PreAlpha
    elseif lowercase_string == "alpha"
        return DevelopmentStage.Alpha
    elseif lowercase_string == "beta"
        return DevelopmentStage.Beta
    elseif lowercase_string == "release candidate"
        return DevelopmentStage.ReleaseCandidate
    elseif lowercase_string == "stable release"
        return DevelopmentStage.StableRelease
    else
        throw(ErrorException("Invalid development stage ($string)"))
    end
end

function is_stable_release(development_stage::DevelopmentStage.T)
    return development_stage == DevelopmentStage.StableRelease
end
