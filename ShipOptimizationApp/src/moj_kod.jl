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
    
    quiver_plot = plot(xlim=(-10,10), ylim=(-10,10), xlabel="x", ylabel="y", title="Pole Wektorowe dla t = $t, T = $T", legend=false)
    quiver!(quiver_plot, [p[1] for p in grid_points], [p[2] for p in grid_points], quiver=(vx_values, vy_values), color=:blue)
    
    # Dodajemy czarny punkt poruszający się od (-10,0) do punktu docelowego (destx, desty)
    vx = (destx + 10) / T
    vy = desty / T

    local x_point = -10 + vx * t
    local y_point = vy * t

    scatter!(quiver_plot, [x_point], [y_point], color=:red, markersize=5)

    quiver!(quiver_plot, [x_point], [y_point], quiver=([vx], [vy]), color=:green, linewidth=2)

    # Obliczamy prędkość kropek w punkcie (x_point, y_point)
    vx_point = vx_custom(x_point, y_point, t, T)
    vy_point = vy_custom(x_point, y_point, t, T)

    # Dodajemy strzałkę będącą przedstawieniem prędkości kropski
    quiver!(quiver_plot, [x_point], [y_point], quiver=([vx_point], [vy_point]), color=:black, linewidth=2)

    local vx_sum = vx + vx_point
    local vy_sum = vy + vy_point

    quiver!(quiver_plot, [x_point], [y_point], quiver=([vx_sum], [vy_sum]), color=:orange, linewidth=2)

    annotate!(quiver_plot, 0.5, -12, text("vx = $vx, vy = $vy", :left, 8))
    annotate!(quiver_plot, 0.5, -13, text("vx_point = $vx_point, vy_point = $vy_point", :left, 8))
    annotate!(quiver_plot, 0.5, -14, text("vx_sum = $vx_sum, vy_sum = $vy_sum", :left, 8))

    push!(quiver_plots, quiver_plot)
end

# Wyświetlenie animacji
anim = @animate for i in 1:length(quiver_plots)
    plot(quiver_plots[i])
end

gif(anim, "vector_field.gif", fps = 3)
