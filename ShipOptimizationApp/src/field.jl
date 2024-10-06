module Field
# Funkcje definiujące składowe wektorów
function v_custom(x, y, t, T, coordinate)
    if lowercase(coordinate) == "x"
        return (x - 30) / 30 * sin(2 * π * t / T) + (y - 40) / 60
    
    elseif lowercase(coordinate) == "y"
        return (0.3 * x + 0.1 * y) * cos(2 * π * t / T)
    end
end

end