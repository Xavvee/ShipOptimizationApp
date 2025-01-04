module Main_Module

    include("includes/includes.jl")
    using .IncludesModule

    using Plots
    using Plots.PlotMeasures
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
        evolved_ships = Evoluate_Module.evolve(pareto_points, g, node_positions, config["evolve_settings"]["num_points"])
        # evolved_ships = sort(evolved_ships, by = ship -> ship.finish_time, rev = true)
        # sorted_ships = sort(ships, by = ship -> ship.fuel_consumption, rev = true)

        # println("------------------")
        # for ship in evolved_ships
        #     println("Fixed: $(ship.path) -> $(ship.finish_time) | $(ship.fuel_consumption)")
        # end
        return ships, evolved_ships
    end

    function simulate_with_gif()
        quiver_plots = Simulation_Module.simulate_multiple_ships(x_range, y_range, T)
        # Wyświetlenie animacji
        anim = Display_Module.display_simulation(quiver_plots)
        
        gif(anim, "vector_field.gif", fps=3)
    end

    # ships1, evolved_ships = simulate_without_gif()
    # simulate_with_gif()

    ships, g, node_positions = Simulation_Module.simulate(T)

    result_ships = Evolution_Algorithm_Module.evolve_with_evolutionary(ships, g, node_positions, 20, 100, 20, 15)
    # println("------------------")
    # for ship in result_ships
    #     println("Fixed: $(ship.path) -> $(ship.finish_time) | $(ship.fuel_consumption)")
    # end

    function display_ship_plots(ships_lists, labels)
        for i in eachindex(ships_lists)
            println("Number of ships in $(labels[i]): $(length(ships_lists[i]))")
        end
    
        # Pierwszy wykres dla wszystkich statków
        
        pl = plot()
        colors = [:red, :green, :blue]
        
        for i in eachindex(ships_lists)
            scatter!(map(x -> x.finish_time, ships_lists[i]), 
                     map(x -> x.fuel_consumption, ships_lists[i]), 
                     label=labels[i], color=colors[i])
        end
    
        xlabel!("Finish Time [h]")
        ylabel!("Fuel Consumption [100 000 l]")
        # display(pl)
        savefig("withRandom.png")

        # Find the fastest ship (with the minimum finish time)
        # all_ships = vcat(ships_lists...)
        # pl_pareto = plot()

        # # Znajdź punkty Pareto
        # pareto_ships = Simulation_Module.find_pareto_points(all_ships)

        # # Dodaj wszystkie statki do wykresu
        # scatter!(pl_pareto, 
        #         map(x -> x.finish_time, all_ships), 
        #         map(x -> x.fuel_consumption, all_ships), 
        #         label="All Paths", color=:gray, alpha=0.5)

        # # Dodaj punkty Pareto do wykresu
        # scatter!(pl_pareto, 
        #         map(x -> x.finish_time, pareto_ships), 
        #         map(x -> x.fuel_consumption, pareto_ships), 
        #         label="Pareto Paths", color=:blue, markersize=5)

        # xlabel!("Finish Time [h]")
        # ylabel!("Fuel Consumption [100 000 l]")
        # # display(pl_pareto)
        # savefig("paretoPoints.png")

        # println("-------------------------------")
        # fastest_ship_index = argmin(map(x -> x.finish_time, all_ships))
        # fastest_ship = all_ships[fastest_ship_index]
        # println("Fastest ship: Finish Time = $(fastest_ship.finish_time), \n Continuous Path = $(fastest_ship.continuous_path), \n Fuel Consumption = $(fastest_ship.fuel_consumption)")

        # println("-------------------------------")
        # # Find the ship with the minimal fuel consumption
        # minimal_fuel_ship_index = argmin(map(x -> x.fuel_consumption, all_ships))
        # minimal_fuel_ship = all_ships[minimal_fuel_ship_index]
        # println("Minimal fuel consumption ship: Fuel Consumption = $(minimal_fuel_ship.fuel_consumption), \n Continuous Path = $(minimal_fuel_ship.continuous_path), \n Finish Time = $(minimal_fuel_ship.finish_time)")
    end
    
    # display_ship_plots([ ships1, evolved_ships, result_ships], [ "Random Paths", "Naive Algorithm Paths", "Genetic Algorithm Paths"])

end