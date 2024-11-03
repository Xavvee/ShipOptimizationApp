module Time_Generator
    struct TimeGenerator
        t::Float64
    end

    function Base.iterate(gen::TimeGenerator, state=gen.t)
        next_state = state + 0.2
        return (state, TimeGenerator(next_state))
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
