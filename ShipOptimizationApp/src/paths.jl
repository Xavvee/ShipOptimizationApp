module Paths

include("create_graph.jl")
using .CreateGraph

using LightGraphs

    function find_random_path(g)
        print(g)

        graph = g[1]
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

end

# println(Paths.find_random_path(CreateGraph.generate_graph( 2, 7, 16, 19, 4, 5, 2, 3)))