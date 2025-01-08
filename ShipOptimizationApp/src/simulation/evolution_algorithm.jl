module Evolution_Algorithm_Module
    using ..IncludesModule
    using Evolutionary
    using StatsBase
    using Colors
    using Plots

    function evolve_with_evolutionary(ships, g, node_positions, num_points, generations, mi, lambda)
        population = ships
        min_sums = Float64[]
        min_times = Float64[]
        min_fuels = Float64[]
        min_sum = Inf 
        min_fuel = Inf
        min_time = Inf
        comparison_plot = plot(title="Comparison between first and last generation")

        for gen in 1:generations
            if(gen // 100 == 0 || gen == 1)
                println("Zaczyna się generacja: $(gen)")
            end
            offspring = Vector{Ship_Module.Ship}()

            for _ in 1:lambda
                random_index = rand(1:mi)
                random_ship = population[random_index]
                points = Vector{Vector{Tuple{Float64, Float64}}}()

                # Generate possible path points
                for vertex in random_ship.path
                    push!(points, Evoluate_Module.find_possible_points(g, node_positions, vertex, num_points))
                end

                # Mutate ship by selecting a new continuous path
                new_ship = Ship_Module.Ship(node_positions[random_ship.path[1]][1], node_positions[random_ship.path[1]][2],
                                         random_ship.finish_x, random_ship.finish_y, random_ship.max_speed, random_ship.path, random_ship.time_step)
                new_ship.continuous_path = [points[j][rand(1:num_points)] for j in 1:length(random_ship.path)]

                Evoluate_Module.evolve_one_ship(new_ship)
                push!(offspring, new_ship)
    
            end

            # Combine parents and offspring
            combined_population = vcat(population, offspring)
            # Select the top mi individuals based on finish time
    
            pareto_population = Simulation_Module.find_pareto_points(combined_population)
            # new_pareto = Vector{Ship_Module.Ship}()
            while length(pareto_population) < mi
                filter!((ship) -> !(ship in pareto_population), combined_population)
                new_pareto = Simulation_Module.find_pareto_points(combined_population)

                if length(pareto_population) + length(new_pareto) > mi
                    new_pareto = sample(new_pareto, min(mi - length(pareto_population), length(new_pareto)), replace=false)
                end

                append!(pareto_population, new_pareto)
            end

            population = pareto_population

            # Find the ship with the minimum sum of fuel_consumption + finish_time in this generation
            # Start with a large value
            for ship in population
                total_sum = ship.fuel_consumption + ship.finish_time
                if total_sum < min_sum
                    min_sum = total_sum
                end
        
                if min_fuel > ship.fuel_consumption
                    min_fuel = ship.fuel_consumption
                end

                if min_time > ship.finish_time
                    min_time = ship.finish_time
                end
            end

            push!(min_sums, min_sum)
            push!(min_fuels, min_fuel)
            push!(min_times, min_time)

            if(gen == 1)
                scatter!(comparison_plot, map(x -> x.finish_time, population), 
                map(x -> x.fuel_consumption, population), 
                label="First generation routes", color=:red)
            end

            if(gen == generations)
                scatter!(comparison_plot, map(x -> x.finish_time, population), 
                map(x -> x.fuel_consumption, population), 
                label="Last generation routes", color=:green)
                xlabel!("Finish Time [h]")
                ylabel!("Fuel Consumption [100 000 l]")
                savefig("generations_comparison.png")
            end
        end

    
        plot(1:generations, min_fuels, xlabel="Generations", ylabel="Fuel Consumption [100 000 l]", legend = false, title="Lowest Fuel Consumption over Generations")

        savefig("generations_best_fuel.png")

        plot(1:generations, min_times, xlabel="Generations", ylabel="Finish time [h]", legend = false, title="Lowest Finish Time over Generations")

        savefig("generations_best_finish_time.png")

        plot(1:generations, min_sums, xlabel="Generations", ylabel="Minimum Fuel + Finish Time", legend = false, title="Evolutionary Progress")

        savefig("generations_best_combined.png")


        # Return the best ships found in each generation for further analysis
        return population
        # return Simulation_Module.find_pareto_points(best_ships)

    end

end
