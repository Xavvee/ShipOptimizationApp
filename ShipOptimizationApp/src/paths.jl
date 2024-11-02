
include("create_graph.jl")
using .Create_Graph
module Paths

include("create_graph.jl")
using .Create_Graph

using LightGraphs

    function find_random_path(graph)
        path = Vector{Int}() 
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


    function find_left_path(g, node_positions, middle_index)
        most_left_path =  Vector{Int}()
        number_of_layers = 0
        if middle_index % 2 == 0
            number_of_layers = 2 * middle_index 
        else
            number_of_layers = 2 * middle_index + 1 
        end 
        number_of_layers = number_of_layers + 1
        layers = []
        prev_neighbors = []
        for vertex in vertices(g)
            neighbors = outneighbors(g, vertex)
            if prev_neighbors == neighbors
                continue
            else
                push!(layers, neighbors)
                prev_neighbors = neighbors
            end
        end
        push!(most_left_path, 1)
        for layer in layers
            if(layer != Int64[])
                push!(most_left_path, layer[1])
            end
        end
        return most_left_path
    end

    function find_right_path(g, node_positions, middle_index)
        most_right_path =  Vector{Int}()
        number_of_layers = 0
        if middle_index % 2 == 0
            number_of_layers = 2 * middle_index 
        else
            number_of_layers = 2 * middle_index + 1 
        end 
        number_of_layers = number_of_layers + 1
        layers = []
        prev_neighbors = []
        for vertex in vertices(g)
            neighbors = outneighbors(g, vertex)
            if prev_neighbors == neighbors
                continue
            else
                push!(layers, neighbors)
                prev_neighbors = neighbors
            end
        end
        push!(most_right_path, 1)
        for layer in layers
            if(layer != Int64[])
                push!(most_right_path, layer[end])
            end
        end
        return most_right_path
    end
    
end

# graph, node_positions, middle_index = Create_Graph.generate_graph( 2, 7, 16, 19, 4, 2, 2, 1)
# println(Paths.find_left_path(graph, node_positions, middle_index))
# println(Paths.find_random_path(graph))
# println(Paths.find_right_path(graph, node_positions, middle_index))