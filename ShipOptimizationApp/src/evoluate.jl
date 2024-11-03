module Evoluate_Module
    include("create_graph.jl")
    using .Create_Graph
    using LightGraphs

    include("ship.jl")
    using .Ship_Module

    include("time_generator.jl")
    using .Time_Generator

    include("field.jl")
    using .Field

    include("utils.jl")
    using .Utils

    function evoluate(ships, g, node_positions, num_points)
        better_ships = Vector{Ship_Module.Ship}() # generalna tablica z lepszymi statkami
        for ship in ships
            modified_ships = Vector{Ship_Module.Ship}() # tablica z "lepszymi statkami" np rozmiaru

            points = Vector{Vector{Tuple{Float64, Float64}}}()
            
            for vertex in ship.path
                push!(points, find_possible_points(g, node_positions, vertex, num_points))
            end
            
            for i in 1:num_points
                new_ship = Ship_Module.Ship(node_positions[ship.path[1]][1], node_positions[ship.path[1]][2], ship.finish_x, ship.finish_y, ship.max_speed, ship.path, ship.time_step)
                new_ship.continuous_path =  [points[j][i] for j in 1:length(ship.path)]
                push!(modified_ships, new_ship)
            end
            better_found = false
            for modified_ship in modified_ships # dla kazdego lepszego statku sprawdz
                evoluate_one_ship(modified_ship)
                if modified_ship.finish_time < ship.finish_time
                    better_found = true
                    push!(better_ships, modified_ship)
                end
            end
            if !better_found
                old_ship = Ship_Module.Ship(node_positions[ship.path[1]][1], node_positions[ship.path[1]][2], ship.finish_x, ship.finish_y, ship.max_speed, ship.path, ship.time_step)
                old_ship.finish_time = ship.finish_time
                push!(better_ships, old_ship)
            end
        end
        return better_ships
    end

    function evoluate_one_ship(ship::Ship_Module.Ship)
        points = ship.continuous_path
        n = length(points)
        T = 24
        local time_generator = Time_Generator.TimeGenerator(0.0)
        local time = 0.0
        while ship.current_node_index < n
            time_generated = Time_Generator.iterate(time_generator)
            if time_generated === nothing
                break
            end
            time, time_generator = time_generated 

            Ship_Module.update_field_speed!(ship, Field.v_custom(ship.position_x, ship.position_y, mod(time, 24), T, "x"), Field.v_custom(ship.position_x, ship.position_y,  mod(time, 24), T, "y"))

            # Update the ship's movement
            next_x, next_y = points[ship.current_node_index+1]
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
                if(norm < v_sum_norm*ship.time_step)
                    remaining_percentage = 1 - (norm/(v_sum_norm*ship.time_step))
                    ship.position_x = next_x
                    ship.position_y = next_y
                    if ship.current_node_index < n - 1
                        tmp_next_x, tmp_next_y = points[ship.current_node_index + 2]
                        tmp_direction_x = tmp_next_x - ship.position_x
                        tmp_direction_y = tmp_next_y - ship.position_y
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
        end
        ship.finish_time = time
        return ship
    end

    using Random

    # Struktura generująca punkty
    struct PointGenerator
        a::Float64   # Nachylenie
        b::Float64   # Punkt przecięcia
        x_start::Float64 # Początkowa wartość x
        x_end::Float64   # Końcowa wartość x
        current_x::Float64 # Aktualna wartość x
    end

    # Funkcja iterująca
    function Base.iterate(gen::PointGenerator)
        # Generujemy losową wartość x w zadanym zakresie
        next_x = rand() * (gen.x_end - gen.x_start) + gen.x_start
        y = gen.a * next_x + gen.b  # Obliczanie y
        
        # Zwracamy nowy punkt
        return ((next_x, y), PointGenerator(gen.a, gen.b, gen.x_start, gen.x_end, next_x))
    end


    function find_possible_points(g, node_positions, current_vertex, num_points)
        lower_range, upper_range = find_range(g, node_positions, current_vertex)
        a, b = line_through_two_points(lower_range, upper_range)
        point_generator = PointGenerator(a, b, lower_range[1], upper_range[1], lower_range[1])
        generated_points = Vector{Tuple{Float64, Float64}}()
        if lower_range==upper_range
            for _ in 1:num_points
                push!(generated_points, lower_range) 
            end
        else
            for _ in 0:num_points
                point_generated = iterate(point_generator)
                point, point_generator = point_generated
                push!(generated_points, point)
            end
        end
        return generated_points
    end

    function line_through_two_points(point1, point2)
        x1, y1 = point1
        x2, y2 = point2
        # Oblicz nachylenie
        a = (y2 - y1) / (x2 - x1)
        # Oblicz b
        b = y1 - a * x1
        return a, b
    end


    function find_range(g, node_positions, current_vertex)
        first_neighbor, second_neighbor = find_nearest(g, node_positions, current_vertex)
        lower_range_vertex = nothing
        upper_range_vertex = nothing
        if isnothing(first_neighbor) && isnothing(second_neighbor)
            lower_range_vertex = current_vertex
            upper_range_vertex = current_vertex 
        elseif isnothing(first_neighbor)
            if node_positions[current_vertex][1] < node_positions[second_neighbor][1]
                lower_range_vertex = current_vertex
                upper_range_vertex = second_neighbor
            else
                lower_range_vertex = second_neighbor
                upper_range_vertex = current_vertex
            end
        elseif isnothing(second_neighbor)
            if node_positions[current_vertex][1] < node_positions[first_neighbor][1]
                lower_range_vertex = current_vertex
                upper_range_vertex = first_neighbor
            else
                lower_range_vertex = first_neighbor
                upper_range_vertex = current_vertex
            end
        else
            if node_positions[first_neighbor][1] < node_positions[second_neighbor][1]
                lower_range_vertex = first_neighbor
                upper_range_vertex = second_neighbor
            else
                lower_range_vertex = second_neighbor
                upper_range_vertex = first_neighbor
            end
        end
        return node_positions[lower_range_vertex], node_positions[upper_range_vertex]
    end

    function find_nearest(g, node_positions, current_vertex)
        neighbors_list = collect(neighbors(g, current_vertex))
        first_neighbor = nothing
        second_neighbor = nothing
        if current_vertex > 1
            if !((current_vertex - 1) in neighbors_list) && !(current_vertex in collect(neighbors(g, (current_vertex - 1))))
                first_neighbor = (current_vertex - 1)
            end
        end
        if current_vertex < length(node_positions)
            if !((current_vertex + 1) in neighbors_list) && !(current_vertex in collect(neighbors(g, (current_vertex + 1))))
                second_neighbor = current_vertex + 1
            end
        end 
        return first_neighbor, second_neighbor
    end

end



# x_start, y_start = 2, 7
# x_finish, y_finish = 16, 19
# k = 4  # Number of segments (k+1 points)
# max_l = 2  # Max number of points on both sides
# m = 2 # Distance of points from the line
# multiplier = 1  # Controls the decrease of points towards the edges

# g, node_positions = Create_Graph.generate_graph(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
# Create_Graph.plot_graph(g, node_positions)

# find_possible_points(g, node_positions, 6, 10)

