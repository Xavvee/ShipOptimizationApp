module Simulation

include("field.jl")
using .Field

include("utils.jl")
using .Utils

include("create_graph.jl")
using .Create_Graph

include("paths.jl")
using .Paths

include("time_generator.jl")
using .Time_Generator

using Plots
using Plots.PlotMeasures
using LightGraphs

# Funkcja do uzyskania celu od użytkownika

function create_custom_range(range_min, range_step, range_max)
    return range_min:range_step:range_max
end

function initialize_quiver_plot(x_range, y_range, time, T, grid_points, vx_values, vy_values, x_curr, y_curr, g, node_positions)

    x_min, x_max = first(x_range), last(x_range)
    y_min, y_max = first(y_range), last(y_range)

    quiver_plot = plot(xlim=(x_min, x_max), ylim=(y_min, y_max), xlabel="x", ylabel="y", title="Pole Wektorowe dla time = $time, T = $T", legend=false, bottom_margin=30px, right_margin=30px)
    
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
    for (_, (x_i, y_i)) in enumerate(node_positions)
        scatter!(quiver_plot, [x_i], [y_i], color=:black, markersize=3, label=false)
    end

    return quiver_plot
end


function calculate_velocity_field(grid_points, time, T)
    vx_values = [Field.v_custom(x, y, time, T, "x") for (x, y) in grid_points]
    vy_values = [Field.v_custom(x, y, time, T, "y") for (x, y) in grid_points]
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

    global time_generator = Time_Generator.TimeGenerator(0.0)
    
    g, node_positions = Create_Graph.generate_graph(x_start, y_start, x_finish, y_finish, 4, 5, 2, 3)
    path = Paths.find_random_path((g, node_positions))

    # Start with the first node in the path
    current_node_index = 1
    current_node = path[current_node_index]
    
    # Get the coordinates for the starting node
    x_curr, y_curr = node_positions[current_node]

    # Main loop to simulate the ship's movement
    while current_node_index < length(path)
       
        time_generated = Time_Generator.iterate(time_generator)
        
        if time_generated === nothing
            break
        end
    
        time, time_generator = time_generated

        # Initialize the velocity field
        vx_values, vy_values = calculate_velocity_field(grid_points, time, T)
        
        # Initialize plot
        quiver_plot = initialize_quiver_plot(x_range, y_range, time, T, grid_points, vx_values, vy_values, x_curr, y_curr, g, node_positions)

        # Calculate speed at the current position
        vx_field = Field.v_custom(x_curr, y_curr, time, T, "x")
        vy_field = Field.v_custom(x_curr, y_curr, time, T, "y")

        # Add velocity field vector
        quiver!(quiver_plot, [x_curr], [y_curr], quiver=([vx_field], [vy_field]), color=:black, linewidth=2)

        # Check if there's a next node
        if current_node_index < length(path)
            next_node = path[current_node_index + 1]
            next_x, next_y = node_positions[next_node]

            # Calculate direction to the next node
            direction_x = next_x - x_curr
            direction_y = next_y - y_curr
            norm = sqrt(direction_x^2 + direction_y^2)

            # Calculate ship direction and speed using the Utils function
            ship_direction = Utils.calculate_ship_direction([vx_field, vy_field], [direction_x, direction_y], vs_speed)
            ship_direction_x, ship_direction_y = ship_direction


            quiver!(quiver_plot, [x_curr], [y_curr], quiver=([ship_direction_x], [ship_direction_y]), color=:magenta, linewidth=2)

            vx_sum = vx_field + ship_direction_x
            vy_sum = vy_field + ship_direction_y
            v_sum_norm = sqrt(vx_sum^2 + vy_sum^2)
            # Normalize movement towards the next node
            quiver!(quiver_plot, [x_curr], [y_curr], quiver=([vx_sum], [vy_sum]), color=:orange, linewidth=2)

            if norm > 0
                # Calculate how far the ship can move towards the next node without overshooting
                if(norm < v_sum_norm)
                    remaining_percentage = 1 - (norm/v_sum_norm)
                    println("Po drugiej stronie: $remaining_percentage")
                    x_curr = next_x
                    y_curr = next_y
                    if current_node_index < length(path) - 1
                        tmp_next_x, tmp_next_y = node_positions[path[current_node_index + 2]]
                        tmp_direction_x = tmp_next_x - x_curr
                        tmp_direction_y = tmp_next_y - y_curr
                        println("tmp x: $tmp_direction_x tmp y $tmp_direction_y")
                        ship_direction = Utils.calculate_ship_direction([vx_field, vy_field], [tmp_direction_x, tmp_direction_y], vs_speed)
                        ship_direction_x, ship_direction_y = ship_direction
                        vx_sum = vx_field + ship_direction_x
                        vy_sum = vy_field + ship_direction_y
                        x_curr += (vx_sum )*remaining_percentage
                        y_curr += (vy_sum )*remaining_percentage
                    end
                    current_node_index += 1
                else
                    # Update current position of the ship
                    x_curr += vx_sum 
                    y_curr += vy_sum 
                end
                
            
            end
        end
        
        # Store plot for the current position
        push!(quiver_plots, quiver_plot)
    end

    return quiver_plots
end


end