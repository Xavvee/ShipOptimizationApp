module Field
# Funkcje definiujące składowe wektorów
function v_custom(x, y, t, T, coordinate)
    if lowercase(coordinate) == "x"
        return (x - 30) / 30 * sin(2 * π * t / T) + (y - 40) / 60
    
    elseif lowercase(coordinate) == "y"
        return (0.3 * x + 0.1 * y) * cos(2 * π * t / T)
    end
end

function custom_destination()
    print("Wprowadź wartości x i y oddzielone spacją: ")
    inputs = split(readline())
    
    x = parse(Float64, inputs[1])
    y = parse(Float64, inputs[2])
    return x, y
end

end