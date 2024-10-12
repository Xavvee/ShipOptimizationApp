module Simulation

include("field.jl")
using .Field

include("utils.jl")
using .Utils

include("create_graph.jl")
using .CreateGraph


using Plots
using Plots.PlotMeasures
using LightGraphs

# Funkcja do uzyskania celu od użytkownika

function create_custom_range(range_min, range_step, range_max)
    return range_min:range_step:range_max
end

function initialize_quiver_plot(x_range, y_range, t, T, grid_points, vx_values, vy_values, x_start, y_start, x_finish, y_finish, x_curr, y_curr, g, node_positions)

    x_min, x_max = first(x_range), last(x_range)
    y_min, y_max = first(y_range), last(y_range)

    quiver_plot = plot(xlim=(x_min, x_max), ylim=(y_min, y_max), xlabel="x", ylabel="y", title="Pole Wektorowe dla t = $t, T = $T", legend=false, bottom_margin=30px, right_margin=30px)
    
    # Plot the velocity field
    quiver!(quiver_plot, [p[1] for p in grid_points], [p[2] for p in grid_points], quiver=(vx_values, vy_values), color=:blue)
    
    # Mark the ship's position
    scatter!(quiver_plot, [x_curr], [y_curr], color=:red, markersize=5)
    
    # Plot the graph edges
    for e in edges(g)
        # Get source and destination nodes from the edge
        src = e.src
        dst = e.dst

        # Get the coordinates of the source and destination nodes
        x_src, y_src = node_positions[src]
        x_dst, y_dst = node_positions[dst]

        # Plot the edge as a line between the source and destination points
        plot!([x_src, x_dst], [y_src, y_dst], seriestype=:line, color=:green, label=false)
    end

    # Plot the graph nodes
    for (i, (x_i, y_i)) in enumerate(node_positions)
        scatter!(quiver_plot, [x_i], [y_i], color=:black, markersize=5, label=false)
    end

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
    # println("Wczytaj punkty początkowe: ")
    # global x_start, y_start = Field.custom_destination()
    # println("Wczytaj punkty końcowe: ")
    # x_finish, y_finish = Field.custom_destination()
    
    global x_start, y_start, x_finish, y_finish = -7.0, 17.0, 26.0, -9.0
    
    vs_speed = 3.0
    # Inicjalizacja listy przechowującej wektory
    quiver_plots = []

    global x_curr, y_curr = x_start, y_start

    # Generowanie punktów siatki
    grid_points = collect(Iterators.product(x_range, y_range))

    global t = -0.5
    
    g, node_positions = CreateGraph.generate_graph(x_start, y_start, x_finish, y_finish, 4, 5, 2 ,3)

    # Pętla po zakresie czasu
    while abs(x_curr) < abs(x_finish) || abs(y_curr) < abs(y_finish)
        global x_curr, y_curr, x_start, y_start
        global t
        t += 0.5
        if t > 23.5
            t = 0.0
        end

        vx_values, vy_values = calculate_velocity_field(grid_points, t, T)
        
        # Initialize plot
        quiver_plot = initialize_quiver_plot(x_range, y_range, t, T, grid_points, vx_values, vy_values, x_start, y_start, x_finish, y_finish, x_curr, y_curr, g, node_positions)

        # Obliczanie prędkości w punkcie (x_start, y_start)
        vx_field = Field.v_custom(x_curr, y_curr, t, T, "x")
        vy_field = Field.v_custom(x_curr, y_curr, t, T, "y")

        # Dodawanie strzałki reprezentującej pole prędkości w danym punkcie
        quiver!(quiver_plot, [x_curr], [y_curr], quiver=([vx_field], [vy_field]), color=:black, linewidth=2)

        ship_direction = Utils.calculate_ship_direction([vx_field, vy_field], [x_finish - x_start, y_finish - y_start], vs_speed)

        ship_direction_x, ship_direction_y = ship_direction

        quiver!(quiver_plot, [x_curr], [y_curr], quiver=([ship_direction_x], [ship_direction_y]), color=:magenta, linewidth=2)

        vx_sum = ship_direction_x + vx_field
        vy_sum = ship_direction_y + vy_field

        quiver!(quiver_plot, [x_curr], [y_curr], quiver=([vx_sum], [vy_sum]), color=:orange, linewidth=2)

        annotate!(quiver_plot, 0.5, -12, text("vx = $(round(ship_direction_x,digits=3)), vy = $(round(ship_direction_y,digits=3))", :left, 8))
        annotate!(quiver_plot, 0.5, -13, text("vx_field = $(round(vx_field,digits=3)), vy_field = $(round(vy_field,digits=3))", :left, 8))
        annotate!(quiver_plot, 0.5, -14, text("vx_sum = $(round(vx_sum,digits=3)), vy_sum = $(round(vy_sum,digits=3))", :left, 8))

        push!(quiver_plots, quiver_plot)
        x_curr += vx_sum
        y_curr += vy_sum
    end
    return quiver_plots
end
    
end

