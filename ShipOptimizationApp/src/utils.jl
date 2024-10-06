module Utils
using LinearAlgebra

function normalize(v::Vector{T}) where T
    norm_v = sqrt(sum(v.^2)) 
    if norm_v == 0
        error("Cannot normalize a zero vector")
    end
    return v / norm_v
end

# Function to calculate the correct ship direction given current and destination vectors
function calculate_ship_direction(vc::Vector{T}, vd::Vector{T}, vs_speed::T) where T
    # Sprawdzenie, czy vs_speed jest większe od długości wektora vc
    if vs_speed <= norm(vc)
        return [-vc[1], -vc[2]]
    end

    direction_to_destination = normalize(vd)
    
    # Step 1: Decompose the current velocity along the desired direction and perpendicular to it
    current_in_dest_direction = dot(vc, direction_to_destination) * direction_to_destination
    current_perpendicular = vc - current_in_dest_direction
    
    # Step 2: The ship must cancel out the perpendicular component of the current
    perpendicular_speed = norm(current_perpendicular)
    
    # Step 3: The remaining velocity magnitude for the ship to go toward the destination
    remaining_speed = sqrt(vs_speed^2 - perpendicular_speed^2)
    
    # Step 4: The ship's velocity is the sum of the remaining velocity in the destination direction
    vs_direction = remaining_speed * direction_to_destination - current_perpendicular
    
    return vs_direction
end


end #koniec modulu

# # Example vectors
# vc = [-2.5, 3.0]  # Current velocity vector
# vd = [7.0, 4.0]   # Desired velocity vector (toward the destination)
# vs_speed = 3.0    # Ship's constant speed

# # Calculate the ship's velocity direction
# vs = calculate_ship_direction(vc, vd, vs_speed)

# println("The ship should go in the direction: $vs")
