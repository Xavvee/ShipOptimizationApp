using Test
using LinearAlgebra
include("../src/simulation/vector_calculations.jl")
using .Vector_Calculations_Module


@testset "normalize Function" begin
    @test normalize([3.0, 4.0]) ≈ [0.6, 0.8]
    @test normalize([1.0, 0.0]) ≈ [1.0, 0.0]
    # @test_throws ErrorException normalize([0.0, 0.0])
end

@testset "calculate_ship_vector Function" begin
    current_vector = [1.0, 2.0]
    direction_vector = [3.0, 4.0]
    vs_speed = 5.0

    result = Vector_Calculations_Module.calculate_ship_vector(current_vector, direction_vector, 2.0)
    @test result ≈ [-1.0, -2.0]

end

@testset "calculate_ship_direction Function" begin
    current_vector = [1.0, 2.0]
    direction_vector = [3.0, 4.0]
    vs_speed = 5.0

    result = Vector_Calculations_Module.calculate_ship_vector(current_vector, direction_vector, 5.0)
    
    expected_direction = normalize(direction_vector)
    current_in_dest_direction = dot(current_vector, expected_direction) * expected_direction
    current_perpendicular = current_vector - current_in_dest_direction
    perpendicular_speed = norm(current_perpendicular)
    remaining_speed = sqrt(vs_speed^2 - perpendicular_speed^2)
    expected_result = remaining_speed * expected_direction - current_perpendicular
    @test result ≈ expected_result

end