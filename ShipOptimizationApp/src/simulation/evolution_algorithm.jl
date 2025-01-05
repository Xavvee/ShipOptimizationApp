module Evolution_Algorithm_Module
    using ..IncludesModule
    using Evolutionary
    using StatsBase
    using Colors
    using Plots

    function evolve_with_evolutionary(ships, g, node_positions, num_points, generations, μ, λ)
        population = ships
        best_ships = Vector{Ship_Module.Ship}()
        min_sums = Float64[]
        min_times = Float64[]
        min_fuels = Float64[]
        min_sum = Inf 
        min_fuel = Inf
        min_time = Inf
        single_parent_children = Int(λ/μ)

        for gen in 1:generations
            offspring = Vector{Ship_Module.Ship}()
            println("Size of population $(length(population))")

            for ship in population
                points = Vector{Vector{Tuple{Float64, Float64}}}()
                
                # Generate possible path points
                for vertex in ship.path
                    push!(points, Evoluate_Module.find_possible_points(g, node_positions, vertex, num_points))
                end
    
                for i in 1:single_parent_children
                    # Mutate ship by selecting a new continuous path
                    new_ship = Ship_Module.Ship(node_positions[ship.path[1]][1], node_positions[ship.path[1]][2],
                                                ship.finish_x, ship.finish_y, ship.max_speed, ship.path, ship.time_step)
                    new_ship.continuous_path = [points[j][rand(1:num_points)] for j in 1:length(ship.path)]

                    Evoluate_Module.evolve_one_ship(new_ship)
                    push!(offspring, new_ship)
                end
            end
            println("Number of offspring $(length(offspring)) should be 280")
            # Combine parents and offspring
            combined_population = vcat(population, offspring)
            println("combined_population size: $(length(combined_population))")
            # Select the top μ individuals based on finish time
    
            pareto_population = Simulation_Module.find_pareto_points(combined_population)
            println("Number of pareto points: $(length(pareto_population))")
            pareto_population = sample(pareto_population, min(μ, length(pareto_population)), replace=false)

            # Store the best ship found in this generation
            append!(best_ships, pareto_population)


            # Update population for the next generation
            population = pareto_population

            # Find the ship with the minimum sum of fuel_consumption + finish_time in this generation
             # Start with a large value
            for ship in pareto_population
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
        end
    
        plot(1:generations, min_fuels, xlabel="Generations", ylabel="Fuel Consumption [100 000 l]", legend = false, title="Lowest Fuel Consumption over Generations")

        savefig("generations_best_fuel.png")

        plot(1:generations, min_times, xlabel="Generations", ylabel="Finish time [h]", legend = false, title="Lowest Finish Time over Generations")

        savefig("generations_best_finish_time.png")

        plot(1:generations, min_sums, xlabel="Generations", ylabel="Minimum Fuel + Finish Time", legend = false, title="Evolutionary Progress")

        savefig("generations_best_combined.png")


        # Return the best ships found in each generation for further analysis
        return best_ships
        # return Simulation_Module.find_pareto_points(best_ships)

    end

end
