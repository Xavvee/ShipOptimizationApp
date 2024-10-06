include("utils.jl")
using .Utils

using Plots
using Plots.PlotMeasures

T = 24

# Funkcje definiujące składowe wektorów
function vx_custom(x, y, t, T)
    return (x - 30) / 30 * sin(2 * π * t / T) + (y - 40) / 60
end

function vy_custom(x, y, t, T)
    return (0.3 * x + 0.1 * y) * cos(2 * π * t / T)
end

# Zakresy dla x, y, t
x_range = -10:4:30
y_range = -10:4:30
t_range = 0:0.5:23.5

# Generowanie punktów siatki
grid_points = collect(Iterators.product(x_range, y_range))

# Inicjalizacja listy przechowującej wektory
quiver_plots = []

# Funkcja do uzyskania celu od użytkownika
function customDestination()
    print("Wprowadź wartości x i y oddzielone spacją: ")
    inputs = split(readline())
    
    x = parse(Float64, inputs[1])
    y = parse(Float64, inputs[2])
    return x, y
end

# Wczytaj cel
destx, desty = customDestination()
vs_speed = 3.0
println("Współrzędne celu: x = $destx, y = $desty,  vs_speed = $vs_speed")

# Deklaracja zmiennych globalnych
global x_add = 0
global y_add = 0
global x_point = -10
global y_point = 0
global t = -0.5
# Pętla po zakresie czasu
while abs(x_point) < abs(destx) || abs(y_point) < abs(desty)
    
    global x_add
    global y_add
    global x_point
    global y_point
    global t
    t += 0.5
    if t > 24
        t=0.0
    end
    println("T: $t")
    println("$x_point, $y_point")

    vx_values = [vx_custom(x, y, t, T) for (x, y) in grid_points]
    vy_values = [vy_custom(x, y, t, T) for (x, y) in grid_points]
    
    quiver_plot = plot(xlim=(-10, 30), ylim=(-10, 30), xlabel="x", ylabel="y", title="Pole Wektorowe dla t = $t, T = $T", legend=false, bottom_margin=30px, right_margin=30px)
    quiver!(quiver_plot, [p[1] for p in grid_points], [p[2] for p in grid_points], quiver=(vx_values, vy_values), color=:blue)

    x_point = -10 + x_add
    y_point = y_add

    scatter!(quiver_plot, [x_point], [y_point], color=:red, markersize=5)

    quiver!(quiver_plot, [-10], [0], quiver=([destx + 10], [desty]), color=:green, linewidth=2)

    # Obliczanie prędkości w punkcie (x_point, y_point)
    vx_field = vx_custom(x_point, y_point, t, T)
    vy_field = vy_custom(x_point, y_point, t, T)

    # Dodawanie strzałki reprezentującej pole prędkości w danym punkcie
    quiver!(quiver_plot, [x_point], [y_point], quiver=([vx_field], [vy_field]), color=:black, linewidth=2)

    ship_direction = Utils.calculate_ship_direction([vx_field, vy_field], [destx + 10, desty], vs_speed)

    ship_direction_x, ship_direction_y = ship_direction

    quiver!(quiver_plot, [x_point], [y_point], quiver=([ship_direction_x], [ship_direction_y]), color=:magenta, linewidth=2)
    println("FIELD: $vx_field, $vy_field, DEST: $destx, $desty, SHIP: $ship_direction_x, $ship_direction_y")

    vx_sum = ship_direction_x + vx_field
    vy_sum = ship_direction_y + vy_field

    println("SUM: $vx_sum, $vy_sum")

    quiver!(quiver_plot, [x_point], [y_point], quiver=([vx_sum], [vy_sum]), color=:orange, linewidth=2)

    annotate!(quiver_plot, 0.5, -12, text("vx = $(round(ship_direction_x,digits=3)), vy = $(round(ship_direction_y,digits=3))", :left, 8))
    annotate!(quiver_plot, 0.5, -13, text("vx_field = $(round(vx_field,digits=3)), vy_field = $(round(vy_field,digits=3))", :left, 8))
    annotate!(quiver_plot, 0.5, -14, text("vx_sum = $(round(vx_sum,digits=3)), vy_sum = $(round(vy_sum,digits=3))", :left, 8))

    push!(quiver_plots, quiver_plot)
    println("ship: $ship_direction_x  $ship_direction_y")
    x_add += vx_sum
    y_add += vy_sum
    println("positions: $(x_add-10.0) $y_add")
    println("$x_point, $y_point")

end

# Wyświetlenie animacji
anim = @animate for i in 1:length(quiver_plots)
    plot(quiver_plots[i])
end

gif(anim, "vector_field.gif", fps=3)
