module Main_Module

    include("utilities/includes.jl")
    using .IncludesModule

    using Plots
    using Plots.PlotMeasures

    # Zakresy dla x, y, t
    using TOML
    config_path = joinpath(@__DIR__, "configuration", "config.toml")
    config = TOML.parsefile(config_path)
    main_ranges = config["main_ranges"]
    x_range_min = main_ranges["x_range_min"]
    x_range_step = main_ranges["x_range_step"]
    x_range_max = main_ranges["x_range_max"]

    y_range_min = main_ranges["y_range_min"]
    y_range_step = main_ranges["y_range_step"]
    y_range_max = main_ranges["y_range_max"]

    t_range_min = main_ranges["t_range_min"]
    t_range_step = main_ranges["t_range_step"]
    t_range_max = main_ranges["t_range_max"]

    x_range = Simulation_Module.create_custom_range(x_range_min, x_range_step, x_range_max)
    y_range = Simulation_Module.create_custom_range(y_range_min, y_range_step, y_range_max)
    t_range = Simulation_Module.create_custom_range(t_range_min, t_range_step, t_range_max)

    T = config["time_settings"]["T"]

    function simulate_without_gif()
    # odpalać na terminalu `julia -t 4`, sprawdazć czy wyświetli odpowiednio - `Threads.nthreads()`
        ships, g, node_positions = Simulation_Module.simulate(T)
        
        # partial_sorted_ships = Simulation_Module.quick_select(ships)
        # # for ship in partial_sorted_ships
        # #     println("$(ship.path) -> $(ship.finish_time) | $(ship.fuel_consumption)")
        # # end

        pareto_points = Simulation_Module.find_pareto_points(ships)
        evoluated_ships = Evoluate_Module.evoluate(pareto_points, g, node_positions, config["evoluate_settings"]["num_points"])
        # evoluated_ships = sort(evoluated_ships, by = ship -> ship.finish_time, rev = true)
        # sorted_ships = sort(ships, by = ship -> ship.fuel_consumption, rev = true)

        # println("------------------")
        # for ship in evoluated_ships
        #     println("Fixed: $(ship.path) -> $(ship.finish_time) | $(ship.fuel_consumption)")
        # end
        return ships, evoluated_ships
    end
    function simulate_with_gif()
        quiver_plots = Simulation_Module.simulate_multiple_ships(x_range, y_range, T)
        # Wyświetlenie animacji
        anim = Display_Module.display_simulation(quiver_plots)
        
        gif(anim, "vector_field.gif", fps=3)
    end

    ships1, evoluated_ships = simulate_without_gif()

    # simulate_with_gif()
    ships, g, node_positions = Simulation_Module.simulate(T)

    result_ships = Evolution_Algorithm_Module.evoluate_with_evolutionary(ships, g, node_positions, 10, 15, 10, 5)
    # println("------------------")
    # for ship in result_ships
    #     println("Fixed: $(ship.path) -> $(ship.finish_time) | $(ship.fuel_consumption)")
    # end

    function display_ship_plots(ships_lists, labels)
        for i in 1:length(ships_lists)
            println("Number of ships in $(labels[i]): $(length(ships_lists[i]))")
        end
    
        pl = plot()
        colors = [:red, :green, :blue]
        
        for i in 1:length(ships_lists)
            scatter!(map(x -> x.finish_time, ships_lists[i]), 
                     map(x -> x.fuel_consumption, ships_lists[i]), 
                     label=labels[i], color=colors[i])
        end
    
        xlabel!("Finish Time")
        ylabel!("Fuel Consumption")
        display(pl)
    end
    
    # Now, you can call the function with the appropriate arguments:
    display_ship_plots([ships1, evoluated_ships, result_ships], ["Ships", "Evoluated Ships", "Result Ships"])
end