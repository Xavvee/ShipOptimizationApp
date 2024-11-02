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

include("ship.jl")
using .Ship_Module

using Plots
using Plots.PlotMeasures
using LightGraphs

using Base.Threads
using Dates

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
    
    # Rysowanie wykresu
    scatter!(quiver_plot, x_curr, y_curr, color=:red, markersize=8)
    
    labels = ["$i" for i in 1:length(x_curr)]  # Tworzenie etykiet dla każdego statku
    
    # Definiowanie przesunięcia (dostosuj te wartości w zależności od potrzeb)
    dx = 1
    dy = 1

    # Dodawanie etykiet do każdego punktu
    for (x, y, label) in zip(x_curr, y_curr, labels)
        annotate!(quiver_plot, x + dx, y + dy, text(label, 10, :black))
    end

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

function simulate_multiple_ships(x_range, y_range, T)
    println("Start loop")
    
    # Define start and finish positions
    global x_start, y_start, x_finish, y_finish = -7.0, 17.0, 26.0, -9.0
    max_speed = 3.0
    quiver_plots = []

    # Generate grid points
    grid_points = collect(Iterators.product(x_range, y_range))

    # Initialize a time generator
    global time_generator = Time_Generator.TimeGenerator(0.0)
    max_l = 7
    multiplier = 2
    g, node_positions, middle_index = Create_Graph.generate_graph(x_start, y_start, x_finish, y_finish, 9, max_l, 2, multiplier)
    time_step = 0.5

    # Create multiple ships with different pathfinding techniques
    # num_ships = 3
    ships = []
    # for i in 1:num_ships
        # if i == 1
            # Use random pathfinding for the first ship
            # path = Paths.find_random_path(g)
        # elseif i == 2
        #     # Use right pathfinding for the second ship
        #     path = Paths.find_right_path(g, max_l, multiplier, middle_index)
        # elseif i == 3
        #     # Use another custom pathfinding method for the third ship
        #     path = Paths.find_left_path(g, max_l, multiplier, middle_index)
        # end
        # ship = Ship_Module.Ship(x_start, y_start, x_finish, y_finish, max_speed, path, time_step)

        # push!(ships, ship)
    # end
    path1 = [1, 4, 9, 20, 37, 41, 52, 57, 59, 60] #42
    path2 = [1, 4, 7, 20, 27, 42, 53, 56, 59, 60] #31
    path3 = [1, 4, 9, 15, 33, 43, 49, 56, 59, 60] #53.5

    ship1 = Ship_Module.Ship(x_start, y_start, x_finish, y_finish, max_speed, path1, time_step)
    ship2 = Ship_Module.Ship(x_start, y_start, x_finish, y_finish, max_speed, path2, time_step)
    ship3 = Ship_Module.Ship(x_start, y_start, x_finish, y_finish, max_speed, path3, time_step)
    push!(ships, ship1)
    push!(ships, ship2)
    push!(ships, ship3)
    # Main loop to simulate the movement of all ships
    while any(ship -> ship.current_node_index < length(ship.path), ships)
        time_generated = Time_Generator.iterate(time_generator)
        if time_generated === nothing
            break
        end
        println("Time generated: ", time_generated)
        time, time_generator = time_generated

        # Initialize the velocity field
        vx_values, vy_values = calculate_velocity_field(grid_points, time, T)

        # Create the plot for this time step
        quiver_plot = initialize_quiver_plot(x_range, y_range, time, T, grid_points, vx_values, vy_values, 
                [ship.position_x for ship in ships], 
                [ship.position_y for ship in ships], 
                g, node_positions)

        for ship in ships

            Ship_Module.update_field_speed!(ship, Field.v_custom(ship.position_x, ship.position_y, mod(time, 24), T, "x"), Field.v_custom(ship.position_x, ship.position_y, mod(time,24), T, "y"))

            # Add velocity field vector
            quiver!(quiver_plot, [ship.position_x], [ship.position_y], quiver=([ship.field_speed_x], [ship.field_speed_y]), color=:black, linewidth=2)
            # If ship reached the end of its path, continue to next iteration
            if ship.current_node_index >= length(ship.path)
                continue
            end

            # Update the ship's movement
            next_x, next_y = node_positions[ship.path[ship.current_node_index + 1]]
            direction_x = next_x - ship.position_x
            direction_y = next_y - ship.position_y
            norm = sqrt(direction_x^2 + direction_y^2)

            # Calculate ship speed and update positions
            ship_direction_x, ship_direction_y = Utils.calculate_ship_direction([ship.field_speed_x, ship.field_speed_y], [direction_x, direction_y], ship.max_speed)
            Ship_Module.update_ship_speed!(ship, ship_direction_x, ship_direction_y)

            quiver!(quiver_plot, [ship.position_x], [ship.position_y], quiver=([ship.ship_speed_x], [ship.ship_speed_y]), color=:magenta, linewidth=2)

            Ship_Module.update_resultant_speed!(ship)

            quiver!(quiver_plot, [ship.position_x], [ship.position_y], quiver=([ship.resultant_speed_x], [ship.resultant_speed_y]), color=:orange, linewidth=2)
            v_sum_norm = sqrt(ship.resultant_speed_x^2 + ship.resultant_speed_y^2)

            if norm > 0
                # Calculate how far the ship can move towards the next node without overshooting
                if(norm < v_sum_norm*ship.time_step)
                    remaining_percentage = 1 - (norm/(v_sum_norm*ship.time_step))
                    # println("Po drugiej stronie: $remaining_percentage")
                    ship.position_x = next_x
                    ship.position_y = next_y
                    if ship.current_node_index < length(ship.path) - 1
                        tmp_next_x, tmp_next_y = node_positions[ship.path[ship.current_node_index + 2]]
                        tmp_direction_x = tmp_next_x - ship.position_x
                        tmp_direction_y = tmp_next_y - ship.position_y
                        # println("tmp x: $tmp_direction_x tmp y $tmp_direction_y")
                        ship_direction_x, ship_direction_y = Utils.calculate_ship_direction([ship.field_speed_x, ship.field_speed_y], [tmp_direction_x, tmp_direction_y], ship.max_speed)
                        Ship_Module.update_ship_speed!(ship, ship_direction_x, ship_direction_y)
                        Ship_Module.update_resultant_speed!(ship)
                        
                        ship.position_x += (ship.resultant_speed_x)*remaining_percentage*ship.time_step
                        ship.position_y += (ship.resultant_speed_y)*remaining_percentage*ship.time_step
                    end
                    ship.current_node_index += 1
                else
                    # Update current position of the ship
                    Ship_Module.move!(ship)
                end
            end
            ship.finish_time = time
        end

        # Store plot for this time step
        push!(quiver_plots, quiver_plot)
    end
    
    println("$(ship1.path) -> $(ship1.finish_time)")
    println("$(ship2.path) -> $(ship2.finish_time)")
    println("$(ship3.path) -> $(ship3.finish_time)")
   

    return quiver_plots
end


function simulate(T)
    println("Start loop for graph")

    global x_start, y_start, x_finish, y_finish = -7.0, 17.0, 26.0, -9.0
    max_speed = 3.0


    
    max_l = 7
    multiplier = 2
    g, node_positions, middle_index = Create_Graph.generate_graph(x_start, y_start, x_finish, y_finish, 9, max_l, 2, multiplier)

    time_step = 0.5
    ships = []

    for _ in 1:8000
        path = Paths.find_random_path(g)
        ship = Ship_Module.Ship(x_start, y_start, x_finish, y_finish, max_speed, path, time_step)
        push!(ships, ship)
    end

    # Lista do przechowywania obiektów `Task` dla każdego statku
    # start_time = now()
    tasks = []
    for ship in ships
        # Tworzymy nowy wątek dla każdego statku
        task = Threads.@spawn begin
            local time_generator = Time_Generator.TimeGenerator(0.0)
            local time = 0.0
            while ship.current_node_index < length(ship.path)
                time_generated = Time_Generator.iterate(time_generator)
                if time_generated === nothing
                    break
                end
                time, time_generator = time_generated 

                Ship_Module.update_field_speed!(ship, Field.v_custom(ship.position_x, ship.position_y, mod(time, 24), T, "x"), Field.v_custom(ship.position_x, ship.position_y,  mod(time, 24), T, "y"))

                # If ship reached the end of its path, continue to next iteration
                if ship.current_node_index >= length(ship.path)
                    continue
                end


                # Update the ship's movement
                next_x, next_y = node_positions[ship.path[ship.current_node_index + 1]]
                direction_x = next_x - ship.position_x
                direction_y = next_y - ship.position_y
                norm = sqrt(direction_x^2 + direction_y^2)

                # Calculate ship speed and update positions
                ship_direction_x, ship_direction_y = Utils.calculate_ship_direction([ship.field_speed_x, ship.field_speed_y], [direction_x, direction_y], ship.max_speed)
                Ship_Module.update_ship_speed!(ship, ship_direction_x, ship_direction_y)

                Ship_Module.update_resultant_speed!(ship)


                v_sum_norm = sqrt(ship.resultant_speed_x^2 + ship.resultant_speed_y^2)

                if norm > 0
                    # Calculate how far the ship can move towards the next node without overshooting
                    if(norm < v_sum_norm*time_step)
                        remaining_percentage = 1 - (norm/(v_sum_norm*time_step))
                        ship.position_x = next_x
                        ship.position_y = next_y
                        if ship.current_node_index < length(ship.path) - 1
                            tmp_next_x, tmp_next_y = node_positions[ship.path[ship.current_node_index + 2]]
                            tmp_direction_x = tmp_next_x - ship.position_x
                            tmp_direction_y = tmp_next_y - ship.position_y
                            ship_direction_x, ship_direction_y = Utils.calculate_ship_direction([ship.field_speed_x, ship.field_speed_y], [tmp_direction_x, tmp_direction_y], ship.max_speed)
                            Ship_Module.update_ship_speed!(ship, ship_direction_x, ship_direction_y)
                            Ship_Module.update_resultant_speed!(ship)
                            
                            ship.position_x += (ship.resultant_speed_x)*remaining_percentage*time_step
                            ship.position_y += (ship.resultant_speed_y)*remaining_percentage*time_step
                        end
                        ship.current_node_index += 1
                    else
                        # Update current position of the ship
                        Ship_Module.move!(ship)
                    end
                end
            end
            ship.finish_time = time
        end

        push!(tasks, task)
    end

    # Czekamy na zakończenie wszystkich zadań
    for task in tasks
        fetch(task)
    end

    # Zapisujemy czas zakończenia
    # end_time = now()
    # elapsed_time = end_time - start_time

    # for ship in ships
    #     println("$(ship.path) -> $(ship.finish_time)")
    # end
    # println("Czas trwania symulacji: $elapsed_time")
    return ships
end


function quick_select(ships)
    n = length(ships)
    # println(n)
    
    # Obliczenie liczby statków, które stanowią 1%
    k = max(1, div(n, 100))  # Upewniamy się, że k nie jest mniejsze niż 1
    
    # Użycie partialsort!, aby znaleźć k największych elementów
    partialsort!(ships, n-k+1:n, by = s -> s.finish_time, rev=true)
    
    # Zmiana rozmiaru wektora, aby usunąć zbędne elementy
    ships = ships[n-k+1:n]
    # println("$(length(ships))")
    return ships
end


end