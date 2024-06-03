using Plots
T = 24

# Funkcje definiujące składowe wektorów
function vx_custom(x, y, t, T)
    return (x-30)/30*sin(2 * π *t/T) + (y-40)/60
end

function vy_custom(x, y, t, T)
    return (0.3*x + 0.1*y) * cos(2 * π *t/T)
end

# Zakresy dla x, y, t
x_range = -10:1:10
y_range = -10:1:10
t_range = 0:0.5:24

# Generowanie współrzędnych punktów siatki
grid_points = collect(Iterators.product(x_range, y_range))

# Inicjalizacja listy przechowującej wektory
quiver_plots = []

# trzeba wywoływać za pomocą terminala include("moj_kod.jl")!!!
# zapisuje jako gif

function customDestination()
    print("Enter the values of x and y separated by a space: ")
    inputs = split(readline())
    
    x = parse(Int, inputs[1])
    y = parse(Int, inputs[2])
    return x, y
end

# Wczytaj cel
destx, desty = customDestination()
println("Destination coordinates: x = $destx, y = $desty")

# Dla każdego punktu na siatce obliczamy wektor
for t in t_range
    vx_values = [vx_custom(x, y, t, T) for (x, y) in grid_points]
    vy_values = [vy_custom(x, y, t, T) for (x, y) in grid_points]
    
    quiver_plot = plot(xlim=(-10,10), ylim=(-10,10), xlabel="x", ylabel="y", title="Pole Wektorowe dla t = $t, T = $T")
    quiver!(quiver_plot, [p[1] for p in grid_points], [p[2] for p in grid_points], quiver=(vx_values, vy_values), color=:blue)
    
    # Dodajemy czarny punkt poruszający się od (-10,0) do punktu docelowego (destx, desty)
    x_point = -10 + (destx + 10) * t / T
    y_point = desty * t / T
    scatter!(quiver_plot, [x_point], [y_point], color=:red, markersize=4)

    push!(quiver_plots, quiver_plot)
end

# Wyświetlenie animacji
anim = @animate for i in 1:length(quiver_plots)
    plot(quiver_plots[i])
end

gif(anim, "vector_field.gif", fps = 3)
