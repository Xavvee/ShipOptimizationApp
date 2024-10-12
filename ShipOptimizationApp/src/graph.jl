module Graph
    using Plots

    # Function to generate points with increasing and decreasing number of dots
    function generate_points(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
        # Calculate directional vector
        dx = x_finish - x_start
        dy = y_finish - y_start
        
        # Length of the vector
        d = sqrt(dx^2 + dy^2)
        
        # Normalized perpendicular vector of length m
        v_perp_x = -dy / d * m
        v_perp_y = dx / d * m
        
        # Points along the line (k+1 points)
        points_on_line = [(x_start + i * dx / k, y_start + i * dy / k) for i in 0:k]
        
        # List to store all points
        all_points = []

        # Calculate the middle index of the line
        middle_index = Int(floor(k / 2))

        for (i, (x_i, y_i)) in enumerate(points_on_line)
            side_points = []
            push!(side_points, (x_i, y_i))

            # Skip the first and last points (edge values)
            if i == 1 || i == length(points_on_line)
                push!(all_points, side_points)
                continue
            end
            
            # Calculate the number of symmetrical points (l) based on the distance to the middle
            l = max_l - multiplier*abs(i - 1 - middle_index)

            for j in 1:l
                # Points on one side
                push!(side_points, (x_i + j * v_perp_x, y_i + j * v_perp_y))
                # Points on the opposite side
                push!(side_points, (x_i - j * v_perp_x, y_i - j * v_perp_y))
            end
            # Add symmetrical points for this point to the list
            push!(all_points, side_points)
        end
        
        return all_points
    end

    # Function to plot points
    function plot_points(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
        all_points = generate_points(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)

        println("Wszystkie punkty: ")
        for row in all_points
            println("Row:")
            for point in row
                println(point)
            end
            println() 
        end
        

        plot([x_start, x_finish], [y_start, y_finish], seriestype=:line, label="Line from start to finish", color=:green, linestyle=:dash)

        # Add symmetrical points to the plot
        for side_points in all_points
            side_x = [x for (x, _) in side_points]
            side_y = [y for (_, y) in side_points]
            scatter!(side_x, side_y, label=false, color=:red, marker=:circle)
        end
        
        xlabel!("x")
        ylabel!("y")
        title!("Symmetrical Points Around Line Segments with Varying Density")
        plot!(legend=:topright, ratio=:equal, grid=true)
    end

    # Example usage
    x_start, y_start = 2, 7
    x_finish, y_finish = 16, 19
    k = 8    # Number of segments (k+1 points)
    max_l = 9  # Maximum number of points on both sides for the middle point
    m = 0.7  # Distance of points from the line
    multiplier = 2

    plot_points(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)

end
