module Graph_Module
    using Plots

    function generate_points(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
        directional_x = x_finish - x_start
        directional_y = y_finish - y_start
        
        d = sqrt(directional_x^2 + directional_y^2)
        
        # Normalized perpendicular vector of length m
        v_perpendicular_x = -directional_y / d * m
        v_perpendicular_y = directional_x / d * m
        
        # Points along the line (k+1 points)
        points_on_line = [(x_start + i * directional_x / k, y_start + i * directional_y / k) for i in 0:k]
        
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
                push!(side_points, (x_i + j * v_perpendicular_x, y_i + j * v_perpendicular_y))
                # Points on the opposite side
                push!(side_points, (x_i - j * v_perpendicular_x, y_i - j * v_perpendicular_y))
            end
            # Add symmetrical points for this point to the list
            push!(all_points, side_points)
        end
        
        return all_points, middle_index 
    end

    function plot_points(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)
        all_points = generate_points(x_start, y_start, x_finish, y_finish, k, max_l, m, multiplier)

        for row in all_points
            println("Row:")
            for point in row
                println(point)
            end
            println() 
        end

        plot([x_start, x_finish], [y_start, y_finish], seriestype=:line, label="Line from start to finish", color=:green, linestyle=:dash)

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

end
