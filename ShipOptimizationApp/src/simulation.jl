module Simulation

include("field.jl")
using .Field

include("utils.jl")
using .Utils

include("create_graph.jl")
using .CreateGraph

include("paths.jl")
using .Paths

using Plots
using Plots.PlotMeasures
using LightGraphs

# Funkcja do uzyskania celu od użytkownika

function create_custom_range(range_min, range_step, range_max)
    return range_min:range_step:range_max
end

function initialize_quiver_plot(x_range, y_range, t, T, grid_points, vx_values, vy_values, x_curr, y_curr, g, node_positions)

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
        scatter!(quiver_plot, [x_i], [y_i], color=:black, markersize=3, label=false)
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

    global x_start, y_start, x_finish, y_finish = -7.0, 17.0, 26.0, -9.0
    vs_speed = 3.0
    quiver_plots = []
    global x_curr, y_curr = x_start, y_start

    # Generating grid points
    grid_points = collect(Iterators.product(x_range, y_range))

    global t = -0.5
    
    g, node_positions = CreateGraph.generate_graph(x_start, y_start, x_finish, y_finish, 4, 5, 2, 3)
    path = Paths.find_random_path((g, node_positions))

    # Start with the first node in the path
    current_node_index = 1
    current_node = path[current_node_index]
    
    # Get the coordinates for the starting node
    x_curr, y_curr = node_positions[current_node]

    # Pętla po zakresie czasu
    while current_node_index < length(path)
        global t
        t += 0.5
        if t > 23.5
            t = 0.0
        end

        # Initialize the velocity field
        vx_values, vy_values = calculate_velocity_field(grid_points, t, T)
        
        # Initialize plot
        quiver_plot = initialize_quiver_plot(x_range, y_range, t, T, grid_points, vx_values, vy_values, x_curr, y_curr, g, node_positions)

        # Calculate speed at the current node
        vx_field = Field.v_custom(x_curr, y_curr, t, T, "x")
        vy_field = Field.v_custom(x_curr, y_curr, t, T, "y")

        # Add velocity field vector
        quiver!(quiver_plot, [x_curr], [y_curr], quiver=([vx_field], [vy_field]), color=:black, linewidth=2)

        # Calculate direction to the next node
        if current_node_index < length(path)
            next_node = path[current_node_index + 1]
            next_x, next_y = node_positions[next_node]

            # Calculate the direction vector
            direction_x = next_x - x_curr
            direction_y = next_y - y_curr
            norm = sqrt(direction_x^2 + direction_y^2)

            # Move the ship towards the next node, normalized by speed
            if norm > 0
                x_curr += (direction_x / norm) * vs_speed
                y_curr += (direction_y / norm) * vs_speed
            end

            println("Current positions: x_curr = $x_curr, y_curr = $y_curr")
            println("CUrrent node index:  $current_node_index")
            println("Norm $norm")
            println("vs speed $vs_speed")
            
            # Check if the ship has reached the next node (within a small threshold)
            if norm < vs_speed
                println("HELLO")
                current_node_index += 1  # Move to the next node in the path
            end
        end

        # Store plot for the current position
        push!(quiver_plots, quiver_plot)
    end

    return quiver_plots
end

    
end

