include("utils.jl")
using .Utils

include("field.jl")
using .Field


using Plots
using Plots.PlotMeasures



x_min = -10
x_step = 4
x_max = 30

y_min = -10
y_step = 2
y_max = 30

T = 24

t_min = 0
t_step = 0.5
t_max = 23.5

# Zakresy dla x, y, t
x_range = x_min:x_step:x_max

y_range = y_min:y_step:y_max

t_range = t_min:t_step:t_max

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

# Deklaracja zmiennych globalnych
global x_point = x_min
global y_point = 0
global t = -0.5
# Pętla po zakresie czasu
println("Start loop")
while abs(x_point) < abs(destx) || abs(y_point) < abs(desty)
    global x_point
    global y_point
    global t
    t += 0.5
    if t > 23.5
        t = 0.0
    end

    vx_values = [Field.v_custom(x, y, t, T, "x") for (x, y) in grid_points]
    vy_values = [Field.v_custom(x, y, t, T, "y") for (x, y) in grid_points]
    
    quiver_plot = plot(xlim=(x_min, x_max), ylim=(y_min, y_max), xlabel="x", ylabel="y", title="Pole Wektorowe dla t = $t, T = $T", legend=false, bottom_margin=30px, right_margin=30px)
    quiver!(quiver_plot, [p[1] for p in grid_points], [p[2] for p in grid_points], quiver=(vx_values, vy_values), color=:blue)
    scatter!(quiver_plot, [x_point], [y_point], color=:red, markersize=5)

    quiver!(quiver_plot, [x_min], [0], quiver=([destx - x_min], [desty]), color=:green, linewidth=2)

    # Obliczanie prędkości w punkcie (x_point, y_point)
    vx_field = Field.v_custom(x_point, y_point, t, T, "x")
    vy_field = Field.v_custom(x_point, y_point, t, T, "y")

    # Dodawanie strzałki reprezentującej pole prędkości w danym punkcie
    quiver!(quiver_plot, [x_point], [y_point], quiver=([vx_field], [vy_field]), color=:black, linewidth=2)

    ship_direction = Utils.calculate_ship_direction([vx_field, vy_field], [destx - x_min, desty], vs_speed)

    ship_direction_x, ship_direction_y = ship_direction

    quiver!(quiver_plot, [x_point], [y_point], quiver=([ship_direction_x], [ship_direction_y]), color=:magenta, linewidth=2)

    vx_sum = ship_direction_x + vx_field
    vy_sum = ship_direction_y + vy_field

    quiver!(quiver_plot, [x_point], [y_point], quiver=([vx_sum], [vy_sum]), color=:orange, linewidth=2)

    annotate!(quiver_plot, 0.5, -12, text("vx = $(round(ship_direction_x,digits=3)), vy = $(round(ship_direction_y,digits=3))", :left, 8))
    annotate!(quiver_plot, 0.5, -13, text("vx_field = $(round(vx_field,digits=3)), vy_field = $(round(vy_field,digits=3))", :left, 8))
    annotate!(quiver_plot, 0.5, -14, text("vx_sum = $(round(vx_sum,digits=3)), vy_sum = $(round(vy_sum,digits=3))", :left, 8))

    push!(quiver_plots, quiver_plot)
    x_point += vx_sum
    y_point += vy_sum
end

# Wyświetlenie animacji
anim = @animate for i in 1:length(quiver_plots)
    plot(quiver_plots[i])
end

gif(anim, "vector_field.gif", fps=3)
