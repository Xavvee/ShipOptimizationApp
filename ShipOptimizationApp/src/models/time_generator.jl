module Time_Generator_Module

    using TOML
    config_path = joinpath(@__DIR__, "../configuration", "config.toml")
    config = TOML.parsefile(config_path)
    time_step = config["time_settings"]["time_step"]
    
    struct TimeGenerator
        t::Float64
    end

    function Base.iterate(gen::TimeGenerator, state=gen.t)
        next_state = state + time_step
        return (state, TimeGenerator(next_state))
    end

end
