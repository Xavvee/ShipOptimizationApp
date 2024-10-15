module Paths

# include("create_graph.jl")
# using .Create_Graph

using LightGraphs

    function find_random_path(graph)
        path = []
        current = 1
        finish = nv(graph)
        while current != finish
            push!(path, current)
            neighbors_list = collect(neighbors(graph, current))
            # Sprawdź, czy sąsiedzi są dostępni
            if isempty(neighbors_list)
                break  # Nie ma więcej sąsiadów, kończymy
            end
            
            # Wybierz losowego sąsiada
            current = rand(neighbors_list)
            
        end
        push!(path, finish)  # Dodaj węzeł końcowy
        return path
    end

    function find_left_path(graph, max_l, multiplier, middle_index)
        path = []
        current = 1
        finish = nv(graph)
        i = 0
        first_grow = true
        last_shrink = true
        while current != finish
            side_points = max_l - multiplier * abs(i+1-middle_index)
            push!(path, current)
            neighbors_list = collect(neighbors(graph, current))
        
            # Sprawdź, czy sąsiedzi są dostępni
            if isempty(neighbors_list)
                break  # Nie ma więcej sąsiadów, kończymy
            end

            if side_points <= 0
                if first_grow && i > middle_index
                    current += 2
                    first_grow = false
                else
                    current += 1
                end
            else
                if last_shrink
                    current += side_points * 2
                    last_shrink = false
                else 
                    current += side_points * 2 + 1
                end
            end
    
            i += 1
        end
        push!(path, finish)  # Dodaj węzeł końcowy
        return path
    end

    function find_right_path(graph, max_l, multiplier, middle_index)
        path = []
        current = 1
        finish = nv(graph)
        i = 0
        while current != finish
            side_points = max_l - multiplier * abs(i+1-middle_index)
            push!(path, current)
            neighbors_list = collect(neighbors(graph, current))
        
            # Sprawdź, czy sąsiedzi są dostępni
            if isempty(neighbors_list)
                break  # Nie ma więcej sąsiadów, kończymy
            end

            if side_points <= 0
                current += 1
            else
               current += side_points * 2 + 1    
            end
    
            i += 1
        end
        push!(path, finish)  # Dodaj węzeł końcowy
        return path
    end
    
end

# println(Paths.find_random_path(Create_Graph.generate_graph( 2, 7, 16, 19, 4, 5, 2, 3)))