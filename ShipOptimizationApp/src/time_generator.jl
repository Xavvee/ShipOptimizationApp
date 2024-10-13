module Time_Generator
    struct TimeGenerator
        t::Float64
    end

    function Base.iterate(gen::TimeGenerator, state=gen.t)
        if state >= 24.0
            return nothing
        else
            next_state = state + 0.5
            if next_state >= 24.0
                next_state = 0.0
            end
            return (state, TimeGenerator(next_state))
        end
    end
end

# global gen = TimeGenerator(0.0)

# # Wydrukuj pierwsze 50 wartości
# for i in 1:50
#     value = iterate(gen)  # Uzyskaj aktualną wartość
#     if value === nothing
#         break  # Zakończ, jeśli nie ma więcej wartości
#     end
#     println(value)  # Wydrukuj aktualną wartość
#     global gen = value[2]  # Zaktualizuj generator, używając globalnego `gen`
# end
