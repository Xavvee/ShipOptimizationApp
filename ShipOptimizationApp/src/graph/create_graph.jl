module Create_Graph_Module

    using ..IncludesModule

    using LightGraphs
    using Plots

    function generate_graph(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
        all_points, middle_index = Graph_Module.generate_points(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
        flattened_points = vcat(all_points...)
    
        # Create a directed graph with the correct number of points
        num_points = length(flattened_points)
        g = SimpleDiGraph(num_points)
        
        # Map each set of points in all_points to a unique index
        point_to_node = Dict{Tuple{Float64, Float64}, Int}()
        node_positions::Vector{Tuple{Float64, Float64}} = Tuple{Float64, Float64}[]
        node_counter = 1  
    
        # Flatten the all_points while ensuring left-to-right numbering
        for side_points in all_points
            sorted_points = sort(side_points, by = p -> p[1])
            
            for point in sorted_points
                if !haskey(point_to_node, point)
                    point_to_node[point] = node_counter
                    push!(node_positions, point)
                    node_counter += 1
                end
            end
        end
        
        # Create edges between points of index i and index i+1
        for i in 1:(length(all_points) - 1)
            for point_i in all_points[i]
                for point_j in all_points[i + 1]
                    add_edge!(g, point_to_node[point_i], point_to_node[point_j])
                end
            end
        end
    
        return g, node_positions, middle_index
    end

    function plot_graph(g, node_positions)
        x_coords = [x for (x, _) in node_positions]
        y_coords = [y for (_, y) in node_positions]
        
        scatter(x_coords, y_coords, label="Nodes", color=:blue, legend=:topright)
        
        for e in edges(g)
            src = e.src
            dst = e.dst
            x_src, y_src = node_positions[src]
            x_dst, y_dst = node_positions[dst]

            plot!([x_src, x_dst], [y_src, y_dst], seriestype=:line, color=:green, label=false)
        end
        
        xlabel!("x")
        ylabel!("y")
        title!("Directed Graph of Symmetrical Points")
        plot!(legend=:topright, ratio=:equal, grid=true)
    end

    function print_graph_connections(g::SimpleDiGraph, node_positions)
        for vertex in vertices(g)
            neighbors = outneighbors(g, vertex)
            current_coords = node_positions[vertex]
            
            println("Vertex $vertex at coordinates $current_coords is connected to: ", 
                    collect(neighbors), 
                    " with coordinates: ", 
                    [node_positions[n] for n in neighbors])
        end
    end

end
