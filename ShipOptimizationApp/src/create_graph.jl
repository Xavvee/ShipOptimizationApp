module Create_Graph

    include("graph.jl")
    using .Graph

    using LightGraphs
    using Plots

    # Function to generate points and create a directed graph
    function generate_graph(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
        # Generate the points
        all_points = Graph.generate_points(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)

        # Create a directed graph
        flattened_points = vcat(all_points...)


        # Create a directed graph with the correct number of points
        num_points = length(flattened_points)
        println("Total number of points: ", num_points)
        g = SimpleDiGraph(num_points)
        
        # Map each set of points in all_points to a unique index
        node_counter = 1
        point_to_node = Dict{Tuple{Float64, Float64}, Int}()
        node_positions = []

        for (i, side_points) in enumerate(all_points)
            for point in side_points
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

        return g, node_positions
    end

    function plot_graph(g, node_positions)
        # Extract x and y coordinates from node positions
        x_coords = [x for (x, y) in node_positions]
        y_coords = [y for (x, y) in node_positions]
        
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


end


# Example usage
# x_start, y_start = 2, 7
# x_finish, y_finish = 16, 19
# k = 4  # Number of segments (k+1 points)
# max_l = 5  # Max number of points on both sides
# m = 2 # Distance of points from the line
# multiplier = 3  # Controls the decrease of points towards the edges

# g, node_positions = Create_Graph.generate_graph(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
# Create_Graph.plot_graph(g, node_positions)
