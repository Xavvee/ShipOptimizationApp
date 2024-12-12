module Simulation_Module

    using  ..IncludesModule

    using Plots
    using Plots.PlotMeasures
    using LightGraphs

    using Base.Threads
    using Dates

    using TOML
    config_path = joinpath(@__DIR__, "../configuration", "config.toml")
    config = TOML.parsefile(config_path)

    generate_graph_settings = config["generate_graph_settings"]

    ship_settings = config["ship_settings"]


    function create_custom_range(range_min, range_step, range_max)
        return range_min:range_step:range_max
    end

    function initialize_quiver_plot(x_range, y_range, time, T, grid_points, vx_values, vy_values, x_curr, y_curr, g, node_positions)
        x_min, x_max = first(x_range), last(x_range)
        y_min, y_max = first(y_range), last(y_range)

        quiver_plot = plot(xlim=(x_min, x_max), ylim=(y_min, y_max), xlabel="Longitude [10km]", ylabel="Latitude [10km]", title="Pole Wektorowe dla time = $time, T = $T", legend=false, bottom_margin=30px, right_margin=30px)
        
        quiver!(quiver_plot, [p[1] for p in grid_points], [p[2] for p in grid_points], quiver=(vx_values, vy_values), color=:blue)
        
        
        
        # labels = ["$i" for i in 1:length(x_curr)]
        labels = ["fastest", "min_fuel"]
        
        # Positions relocation on the plot
        dx = 2
        dy = 2

        for (x, y, label) in zip(x_curr, y_curr, labels)
            annotate!(quiver_plot, x + dx, y + dy, text(label, 12, :black))
        end

        for e in edges(g)
            src = e.src
            dst = e.dst

            x_src, y_src = node_positions[src]
            x_dst, y_dst = node_positions[dst]

            plot!([x_src, x_dst], [y_src, y_dst], seriestype=:line, color=:green, label=false)
        end

        for (_, (x_i, y_i)) in enumerate(node_positions)
            scatter!(quiver_plot, [x_i], [y_i], color=:black, markersize=3, label=false)
        end
        scatter!(quiver_plot, x_curr, y_curr, color=:red, markersize=8)
        return quiver_plot
    end


    function calculate_velocity_field(grid_points, time, T)
        vx_values = [Field_Module.v_custom(x, y, time, T, "x") for (x, y) in grid_points]
        vy_values = [Field_Module.v_custom(x, y, time, T, "y") for (x, y) in grid_points]
        return vx_values, vy_values
    end

    function simulate_multiple_ships(x_range, y_range, T)
        println("Start loop")
        
        x_start = ship_settings["x_start"]
        y_start = ship_settings["y_start"]
        x_finish = ship_settings["x_finish"]
        y_finish = ship_settings["y_finish"]
        max_speed = ship_settings["max_speed"]
        quiver_plots = []

        grid_points = collect(Iterators.product(x_range, y_range))

        global time_generator = Time_Generator_Module.TimeGenerator(0.0)
        max_l = generate_graph_settings["max_l"]
        multiplier = generate_graph_settings["multiplier"]
        k = generate_graph_settings["k"]
        m = generate_graph_settings["m"]
        g, node_positions, middle_index = Create_Graph_Module.generate_graph(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
        time_step = config["time_settings"]["time_step"]
        ships = []

        path1 = [1, 4, 9, 20, 37, 41, 52, 57, 59, 60] #42
        path2 = [1, 4, 7, 20, 27, 42, 53, 56, 59, 60] #31
        # path3 = [1, 4, 9, 15, 33, 43, 49, 56, 59, 60] #53.5
        ship1 = Ship_Module.Ship(x_start, y_start, x_finish, y_finish, max_speed, path1, time_step)
        ship2 = Ship_Module.Ship(x_start, y_start, x_finish, y_finish, max_speed, path2, time_step)
        # ship3 = Ship_Module.Ship(x_start, y_start, x_finish, y_finish, max_speed, path3, time_step)
        ship1.continuous_path = [(-7.0, 17.0), (-3.1870212011632515, 14.296814971173138), (0.6888844479022929, 11.67349863686744), (4.93585851300315, 9.521153753683485), (8.406910280420265, 6.383984415747088), (11.297534654760321, 2.5101187712128876), (14.189966951505207, -1.361452202576725), (18.62775586525996, -3.271609008623045), (22.333333333333332, -6.111111111111111), (26.0, -9.0)]
        ship2.continuous_path = [(-7.0, 17.0), (-4.015911286500617, 13.244762170552635), (1.7522897415828866, 13.023205355769733), (9.998707190970276, 15.947077075718685), (12.621701101075779, 11.733526611194474), (14.701287475669334, 6.830266582366637), (17.207458227318362, 2.468440570570742), (19.53385587354616, -2.121558998105943), (22.333333333333332, -6.111111111111111), (26.0, -9.0)]

        push!(ships, ship1)
        push!(ships, ship2)
        # push!(ships, ship3)

        while any(ship -> ship.current_node_index < length(ship.path), ships)
            time_generated = Time_Generator_Module.iterate(time_generator)
            if time_generated === nothing
                break
            end

            time, time_generator = time_generated
            time = round(time, digits=4)

            vx_values, vy_values = calculate_velocity_field(grid_points, time, T)

            quiver_plot = initialize_quiver_plot(x_range, y_range, time, T, grid_points, vx_values, vy_values, 
                    [ship.position_x for ship in ships], 
                    [ship.position_y for ship in ships], 
                    g, node_positions)

            for ship in ships
                points = ship.continuous_path
                time_consumed = 0.0

                Ship_Module.update_field_speed!(ship, Field_Module.v_custom(ship.position_x, ship.position_y, mod(time, 24), T, "x"), Field_Module.v_custom(ship.position_x, ship.position_y,  mod(time, 24), T, "y"))

                quiver!(quiver_plot, [ship.position_x], [ship.position_y], quiver=([ship.field_speed_x], [ship.field_speed_y]), color=:black, linewidth=2)
    
                if ship.current_node_index >= length(ship.path)
                    continue
                end

                next_x, next_y = points[ship.current_node_index+1]
                direction_x = next_x - ship.position_x
                direction_y = next_y - ship.position_y
                norm = sqrt(direction_x^2 + direction_y^2)

                ship_direction_x, ship_direction_y = Vector_Calculations_Module.calculate_ship_direction([ship.field_speed_x, ship.field_speed_y], [direction_x, direction_y], ship.max_speed)
                Ship_Module.update_ship_speed!(ship, ship_direction_x, ship_direction_y)

                quiver!(quiver_plot, [ship.position_x], [ship.position_y], quiver=([ship.ship_speed_x], [ship.ship_speed_y]), color=:magenta, linewidth=2)

                Ship_Module.update_resultant_ship_speed!(ship)

                quiver!(quiver_plot, [ship.position_x], [ship.position_y], quiver=([ship.resultant_speed_x], [ship.resultant_speed_y]), color=:orange, linewidth=2)
                v_sum_norm = sqrt(ship.resultant_speed_x^2 + ship.resultant_speed_y^2)

                if norm > 0
                    if(norm < v_sum_norm*ship.time_step)
                        remaining_percentage = 1 - (norm/(v_sum_norm*ship.time_step))
                        ship.position_x = next_x
                        ship.position_y = next_y
                        if ship.current_node_index < length(ship.path) - 1
                            tmp_next_x, tmp_next_y = points[ship.current_node_index + 2]
                            tmp_direction_x = tmp_next_x - ship.position_x
                            tmp_direction_y = tmp_next_y - ship.position_y

                            ship_direction_x, ship_direction_y = Vector_Calculations_Module.calculate_ship_direction([ship.field_speed_x, ship.field_speed_y], [tmp_direction_x, tmp_direction_y], ship.max_speed)
                            Ship_Module.update_ship_speed!(ship, ship_direction_x, ship_direction_y)
                            Ship_Module.update_resultant_ship_speed!(ship)
                            
                            ship.position_x += (ship.resultant_speed_x)*remaining_percentage*ship.time_step
                            ship.position_y += (ship.resultant_speed_y)*remaining_percentage*ship.time_step
                        end
                        ship.current_node_index += 1
                        if ship.current_node_index == length(ship.path)
                            time_consumed = round(time_step*(1 - remaining_percentage), digits=4)
                        end
                    else
                        Ship_Module.move_ship!(ship)
                    end
                end
                ship.finish_time = round(time + time_consumed, digits=4)
            end

            push!(quiver_plots, quiver_plot)
        end
        
        println("$(ship1.path) -> $(ship1.finish_time)")
        println("$(ship2.path) -> $(ship2.finish_time)")
        # println("$(ship3.path) -> $(ship3.finish_time)")
    
        return quiver_plots
    end


    function simulate(T)
        println("Start loop for graph")

        x_start = ship_settings["x_start"]
        y_start = ship_settings["y_start"]
        x_finish = ship_settings["x_finish"]
        y_finish = ship_settings["y_finish"]
        max_speed = ship_settings["max_speed"]

        max_l = generate_graph_settings["max_l"]
        multiplier = generate_graph_settings["multiplier"]
        k = generate_graph_settings["k"]
        m = generate_graph_settings["m"]
        g, node_positions, _ = Create_Graph_Module.generate_graph(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)

        time_step = config["time_settings"]["time_step"]
        ships = Vector{Ship_Module.Ship}()

        tasks = [] 
        ship_lock = ReentrantLock()
        ships_amount = config["simulation_settings"]["ships_amount"]
        for _ in 1:ships_amount
            task = @spawn begin
                path = Paths_Module.find_random_path(g)
                ship = Ship_Module.Ship(x_start, y_start, x_finish, y_finish, max_speed, path, time_step)
                for vertex in path
                    push!(ship.continuous_path, node_positions[vertex])
                end
                
                lock(ship_lock) do
                    push!(ships, ship)
                end
            end
            push!(tasks, task)
        end

        for task in tasks
            fetch(task)
        end

        tasks = []
        for ship in ships
            task = Threads.@spawn begin
                Evoluate_Module.evolve_one_ship(ship)
            end
            push!(tasks, task)
        end

        for task in tasks
            fetch(task)
        end

        return ships, g, node_positions
    end


    function quick_select(ships)
        n = length(ships) 
        k = max(1, div(n, 100)) 
        partialsort!(ships, n-k+1:n, by = s -> s.finish_time, rev=true)
        ships = ships[n-k+1:n]
        return ships
    end


    function find_pareto_points(ships)
        sort!(ships, by = x -> (x.finish_time, x.fuel_consumption))

        max_fuel = Inf
        pareto_points = []

        for ship in ships
            if ship.fuel_consumption < max_fuel
                push!(pareto_points, ship)  
                max_fuel = ship.fuel_consumption
            end
        end
        
        return pareto_points
    end

end