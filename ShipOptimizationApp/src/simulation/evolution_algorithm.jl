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
    
   
end
