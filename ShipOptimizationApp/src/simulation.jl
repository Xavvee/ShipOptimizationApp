module Simulation

include("field.jl")
using .Field

include("utils.jl")
using .Utils


using Plots
using Plots.PlotMeasures

# Funkcja do uzyskania celu od użytkownika
function custom_destination()
    print("Wprowadź wartości x i y oddzielone spacją: ")
    inputs = split(readline())
    
    x = parse(Float64, inputs[1])
    y = parse(Float64, inputs[2])
    return x, y
end

function create_custom_range(range_min, range_step, range_max)
    return range_min:range_step:range_max
end

function initialize_quiver_plot(x_range, y_range, t, T, grid_points, vx_values, vy_values, x_point, y_point, destx, desty)

    x_min, x_max = first(x_range), last(x_range)
    y_min, y_max = first(y_range), last(y_range)

    quiver_plot = plot(xlim=(x_min, x_max), ylim=(y_min, y_max), xlabel="x", ylabel="y", title="Pole Wektorowe dla t = $t, T = $T", legend=false, bottom_margin=30px, right_margin=30px)
    
    # Plot the velocity field
    quiver!(quiver_plot, [p[1] for p in grid_points], [p[2] for p in grid_points], quiver=(vx_values, vy_values), color=:blue)
    
    # Mark the ship's position
    scatter!(quiver_plot, [x_point], [y_point], color=:red, markersize=5)
    
    # Mark the destination point
    quiver!(quiver_plot, [x_min], [0], quiver=([destx - x_min], [desty]), color=:green, linewidth=2)
    
    return quiver_plot
end

function calculate_velocity_field(grid_points, t, T)
    vx_values = [Field.v_custom(x, y, t, T, "x") for (x, y) in grid_points]
    vy_values = [Field.v_custom(x, y, t, T, "y") for (x, y) in grid_points]
    return vx_values, vy_values
end

function simulate(x_range, y_range, T)
    println("Start loop")
    # Wczytaj cel
    destx, desty = custom_destination()

    vs_speed = 3.0
    # Inicjalizacja listy przechowującej wektory
    quiver_plots = []

    # Generowanie punktów siatki
    grid_points = collect(Iterators.product(x_range, y_range))

    global x_point = first(x_range)
    global y_point = 0
    global t = -0.5

    # Pętla po zakresie czasu
    while abs(x_point) < abs(destx) || abs(y_point) < abs(desty)
        global x_point
        global y_point
        global t
        t += 0.5
        if t > 23.5
            t = 0.0
        end

        vx_values, vy_values = calculate_velocity_field(grid_points, t, T)
        
        # Initialize plot
        quiver_plot = initialize_quiver_plot(x_range, y_range, t, T, grid_points, vx_values, vy_values, x_point, y_point, destx, desty)

        # Obliczanie prędkości w punkcie (x_point, y_point)
        vx_field = Field.v_custom(x_point, y_point, t, T, "x")
        vy_field = Field.v_custom(x_point, y_point, t, T, "y")

        # Dodawanie strzałki reprezentującej pole prędkości w danym punkcie
        quiver!(quiver_plot, [x_point], [y_point], quiver=([vx_field], [vy_field]), color=:black, linewidth=2)

        ship_direction = Utils.calculate_ship_direction([vx_field, vy_field], [destx - first(x_range), desty], vs_speed)

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
    return quiver_plots
end
    
end