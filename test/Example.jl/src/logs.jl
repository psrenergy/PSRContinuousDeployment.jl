function open_logger(path::String)
    io_model = open(joinpath(path, "example.log"), "w+")

    fmt_file(io, args) = println(io, "[", Dates.format(now(), "yyyy-mm-dd HH:MM:SS"), "] ", "[", args.level, "] ", args.message)
    fmt_console(io, args) = println(io, args.message)

    sink_model = FormatLogger(fmt_file, io_model)
    sink_console = FormatLogger(fmt_console, stderr)

    global_logger(TeeLogger(sink_model, sink_console))

    return function close_logger()
        global_logger(ConsoleLogger())

        flush(io_model)
        close(io_model)

        return nothing
    end
end
