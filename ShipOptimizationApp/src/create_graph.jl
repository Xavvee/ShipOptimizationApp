module Create_Graph

    include("graph.jl")
    using .Graph

    using LightGraphs
    using Plots

    function generate_graph(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
        # Generate the points
        all_points, middle_index = Graph.generate_points(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
        # Create a directed graph
        flattened_points = vcat(all_points...)
    
        # Create a directed graph with the correct number of points
        num_points = length(flattened_points)
        println("Total number of points: ", num_points)
        g = SimpleDiGraph(num_points)
        
        # Map each set of points in all_points to a unique index
        point_to_node = Dict{Tuple{Float64, Float64}, Int}()
        node_positions::Vector{Tuple{Float64, Float64}} = Tuple{Float64, Float64}[]  # Ensure correct type
        node_counter = 1  
    
        # Flatten the all_points while ensuring left-to-right numbering
        for side_points in all_points
            # Sort side_points based on x-coordinate to number left to right
            sorted_points = sort(side_points, by = p -> p[1])  # Sort by x-coordinate
            
            for point in sorted_points
                if !haskey(point_to_node, point)
                    point_to_node[point] = node_counter
                    push!(node_positions, point)  # Save the point coordinates for plotting
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
        # Extract x and y coordinates from node positions
        x_coords = [x for (x, _) in node_positions]
        y_coords = [y for (_, y) in node_positions]
        
        # Plot the nodes
        scatter(x_coords, y_coords, label="Nodes", color=:blue, legend=:topright)
        
        # Add edges
        for e in edges(g)
            # Get source and destination nodes from the edge
            src = e.src
            dst = e.dst

            # Get the coordinates of the source and destination nodes
            x_src, y_src = node_positions[src]
            x_dst, y_dst = node_positions[dst]

            # Plot the edge as a line between the source and destination points
            plot!([x_src, x_dst], [y_src, y_dst], seriestype=:line, color=:green, label=false)
        end
        
        xlabel!("x")
        ylabel!("y")
        title!("Directed Graph of Symmetrical Points")
        plot!(legend=:topright, ratio=:equal, grid=true)
    end

    function print_graph_connections(g::SimpleDiGraph, node_positions)
        # Iterate over each vertex in the graph
        for vertex in vertices(g)
            # Get the outgoing neighbors (connected vertices)
            neighbors = outneighbors(g, vertex)
    
            # Retrieve the coordinates of the current vertex
            current_coords = node_positions[vertex]
            
            # Print the vertex number, its coordinates, and its connections
            println("Vertex $vertex at coordinates $current_coords is connected to: ", 
                    collect(neighbors), 
                    " with coordinates: ", 
                    [node_positions[n] for n in neighbors])
        end
    end
    

end



# Example usage
# x_start, y_start = -7.0, 17.0
# x_finish, y_finish = 26.0, -9.0
# k = 9  # Number of segments (k+1 points)
# max_l = 7  # Max number of points on both sides
# m = 2 # Distance of points from the line
# multiplier = 2 # Controls the decrease of points towards the edges

# g, node_positions = Create_Graph.generate_graph(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
# # Create_Graph.print_graph_connections(g, node_positions)

# Create_Graph.plot_graph(g, node_positions)

