module Evolution_Algorithm_Module
    using ..IncludesModule
    using Evolutionary

    function evoluate_with_evolutionary(ships, g, node_positions, num_points, generations, μ, λ)
        # Initial population
        population = ships
        best_ships = Vector{Ship_Module.Ship}()
    
        for gen in 1:generations
            # Generate offspring by mutation
            offspring = Vector{Ship_Module.Ship}()
            
            for ship in population
                points = Vector{Vector{Tuple{Float64, Float64}}}()
                
                # Generate possible path points
                for vertex in ship.path
                    push!(points, Evoluate_Module.find_possible_points(g, node_positions, vertex, num_points))
                end
    
                for i in 1:λ
                    # Mutate ship by selecting a new continuous path
                    new_ship = Ship_Module.Ship(node_positions[ship.path[1]][1], node_positions[ship.path[1]][2],
                                                ship.finish_x, ship.finish_y, ship.max_speed, ship.path, ship.time_step)
                    new_ship.continuous_path = [points[j][rand(1:num_points)] for j in 1:length(ship.path)]


                    Evoluate_Module.evoluate_one_ship(new_ship)
                    push!(offspring, new_ship)
                end
            end
    
            # Combine parents and offspring
            combined_population = vcat(population, offspring)
    
            # Select the top μ individuals based on finish time
            sorted_population = sort!(combined_population, by = ship -> ship.finish_time)
            population = sorted_population[1:μ]
    
            # Store the best ship found in this generation
            push!(best_ships, population[1])
        end
    
        # Return the best ships found in each generation for further analysis
        return best_ships
    end
    

    # function fitness_function(ship::Ship_Module.Ship, g, node_positions, num_points)
    #     modified_ships = Vector{Ship_Module.Ship}()
    #     points = Vector{Vector{Tuple{Float64, Float64}}}()
        
    #     # Generate the possible points for each vertex in the path
    #     for vertex in ship.path
    #         push!(points, find_possible_points(g, node_positions, vertex, num_points))
    #     end
        
    #     # Generate new ship instances with modified paths
    #     for i in 1:num_points
    #         new_ship = Ship_Module.Ship(node_positions[ship.path[1]][1], node_positions[ship.path[1]][2], 
    #                                     ship.finish_x, ship.finish_y, ship.max_speed, ship.path, ship.time_step)
    #         new_ship.continuous_path = [points[j][i] for j in 1:length(ship.path)]
    #         push!(modified_ships, new_ship)
    #     end
        
    #     # Evaluate each modified ship and return the best one based on finish time
    #     best_ship = modified_ships[1]
    #     for modified_ship in modified_ships
    #         evoluate_one_ship(modified_ship)
    #         if modified_ship.finish_time < best_ship.finish_time
    #             best_ship = modified_ship
    #         end
    #     end
        
    #     # Return the fitness as the negative finish time (since we want to minimize time)
    #     return -best_ship.finish_time
    # end
    
    # # Define the GA setup for optimizing ship routes
    # function ga_optimization(ships, g, node_positions, num_points, population_size=100, generations=50)
    #     # Define the chromosome (individual) representation (e.g., ship path or parameters)
    #     function individual()
    #         # Initialize the individual (e.g., random ship path or parameters)
    #         return rand(1:num_points, length(ships))
    #     end
    
    #     # Fitness function to be used with the genetic algorithm
    #     fitness(x) = fitness_function(ships[x], g, node_positions, num_points)
    
    #     # Define selection, crossover, and mutation strategies
    #     ga_result = Evolutionary.optimize(
    #         fitness,
    #         individual, # Create an individual (chromosome)
    #         GA(
    #             populationSize = population_size,
    #             selection = susinv,  # Stochastic Universal Sampling (susinv)
    #             crossover = DC,  # Discrete Crossover
    #             mutation = PLM()
    #         )
    #     )
    
    #     return ga_result
    # end


   
end
