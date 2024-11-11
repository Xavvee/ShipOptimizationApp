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

        non_dominated_points = Simulation_Module.find_non_dominated_points(ships)
        evoluated_ships = Evoluate_Module.evoluate(non_dominated_points, g, node_positions, config["evoluate_settings"]["num_points"])
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

    println(length(ships1))
    println(length(evoluated_ships))
    println(length(result_ships))

    pl = plot()
    scatter!(map(x -> x.finish_time, ships), map(x -> x.fuel_consumption, ships), label="Ships", color=:red)
    scatter!(map(x -> x.finish_time, evoluated_ships), map(x -> x.fuel_consumption, evoluated_ships), label="Evoluated Ships", color=:green)
    scatter!(map(x -> x.finish_time, result_ships), map(x -> x.fuel_consumption, result_ships), label="Result Ships", color=:blue)

    # # Dodanie etykiet osi
    xlabel!("Finish Time")
    ylabel!("Fuel Consumption")
    # xlims!(13, 16) 
    # ylims!(1.7, 2.5)
    display(pl)
end