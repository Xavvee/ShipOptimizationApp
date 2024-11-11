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

# # Uzyskaj dostęp do `TimeGenerator` z modułu `Time_Generator_Module`
# global gen = Time_Generator_Module.TimeGenerator(0.0)

# # Wydrukuj pierwsze 50 wartości
# for i in 1:50
#     value = iterate(gen)  # Uzyskaj aktualną wartość
#     if value === nothing
#         break  # Zakończ, jeśli nie ma więcej wartości
#     end
#     println(value)  # Wydrukuj aktualną wartość
#     global gen = value[2]  # Zaktualizuj generator, używając globalnego `gen`
# end
