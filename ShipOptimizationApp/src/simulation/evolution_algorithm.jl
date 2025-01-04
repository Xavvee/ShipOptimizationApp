module Evolution_Algorithm_Module
    using ..IncludesModule
    using Evolutionary
    using StatsBase
    using Colors
    using Plots

    function evolve_with_evolutionary(ships, g, node_positions, num_points, generations, μ, λ)
        population = ships
        best_ships = Vector{Ship_Module.Ship}()

        # colors = distinguishable_colors(generations)
        colors = rainbow_colors(generations)

        # Przygotowanie wykresu
        plot(title="Fuel Consumption vs Finish Time per Generation",
            xlabel="Finish Time",
            ylabel="Fuel Consumption")
    


        for gen in 1:generations
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

                    Evoluate_Module.evolve_one_ship(new_ship)
                    push!(offspring, new_ship)
                end
            end
    
            # Combine parents and offspring
            combined_population = vcat(population, offspring)
    
            # Select the top μ individuals based on finish time
            
            # sorted_population = sort!(combined_population, by = ship -> ship.finish_time)
            # population = sorted_population[1:μ]
            
            pareto_population = Simulation_Module.find_pareto_points(combined_population)
            pareto_population = sample(pareto_population, min(μ, length(pareto_population)), replace=false)

            # Store the best ship found in this generation
            append!(best_ships, pareto_population)


            
            # Plot data for this generation directly
            scatter!([ship.finish_time for ship in pareto_population], 
                    [ship.fuel_consumption for ship in pareto_population],
                    color=colors[gen], label="Generation $gen", ms=4)

            # Dodajemy adnotacje do punktów
            used_positions = Set{Tuple{Float64, Float64}}()
            for ship in pareto_population
                if (ship.finish_time, ship.fuel_consumption) in used_positions
                    continue
                end

                push!(used_positions, (ship.finish_time, ship.fuel_consumption))
                annotate!(ship.finish_time, ship.fuel_consumption, 
                        text("$gen", 8, 8, font=(:normal, 8)))  # Używamy 'font' zamiast 'fontsize'
            end

            # Update population for the next generation
            population = pareto_population
        end
    
        savefig("generations3.png")
        # Return the best ships found in each generation for further analysis
        return best_ships
        # return Simulation_Module.find_pareto_points(best_ships)

    end
    
    function rainbow_colors(num_colors::Int)
        colors =[
            RGB{Float64}(1.0,1.0,1.0),
            RGB{Float64}(1.0,0.75,0.75), 
            RGB{Float64}(1.0,0.5,1.0), 
            RGB{Float64}(1.0,0.0,0.0), 
            RGB{Float64}(0.6,0.04,0.0), 
            RGB{Float64}(0.7142857142857143,1.0,0.0), 
            RGB{Float64}(0.9,1.0,0.0), 
            RGB{Float64}(0.0,1.0,0.14285714285714302),
            RGB{Float64}(0.0,0.5,0.0),  
            RGB{Float64}(0.0,1.0,1.0), 
            RGB{Float64}(0.0,0.5714285714285716,1.0), 
            RGB{Float64}(0.0,0.14285714285714257,1.0), 
            RGB{Float64}(0.733,0.0,1.0),  
            RGB{Float64}(0.75,0.75,0.75),
            RGB{Float64}(0.2,0.0,0.2)]
        println(colors)
        return colors
    end
end
