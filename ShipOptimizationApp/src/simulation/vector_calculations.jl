module Vector_Calculations_Module
    using LinearAlgebra

    function normalize(v::Vector{T}) where T 
        norm_v = sqrt(sum(v.^2)) 
        if norm_v == 0.0
            throw(ErrorException("Cannot normalize a zero vector"))
        end
        return v / norm_v
    end

    function calculate_ship_vector(current_vector::Vector{T}, direction_vector::Vector{T}, vs_speed::T) where T
        if vs_speed <= norm(current_vector)
            return [-current_vector[1], -current_vector[2]]
        end

        direction_to_destination = normalize(direction_vector)
        
        current_in_dest_direction = dot(current_vector, direction_to_destination) * direction_to_destination
        current_perpendicular = current_vector - current_in_dest_direction
        
        perpendicular_speed = norm(current_perpendicular)

        remaining_speed = sqrt(vs_speed^2 - perpendicular_speed^2)
        
        vs_direction = remaining_speed * direction_to_destination - current_perpendicular
        return vs_direction
    end

    # Function to calculate the vector the ship should generate to achieve a target direction and speed
    function calculate_ship_direction(current_vector::Vector{T}, direction_vector::Vector{T}, max_speed::T) where T
        direction_to_destination = normalize(direction_vector)

        target_velocity = max_speed * direction_to_destination
        
        required_vector = target_velocity - current_vector
        return required_vector
    end

end

