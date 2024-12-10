using Test
include("../src/models/fuel_consumption.jl")
using .Fuel_Consumption_Module

@testset "Fuel_Consumption_Module Tests" begin

    # Test for integral_for_r function
    @testset "integral_for_r Function" begin

        # Test 1: Zero time frame (t_fr = 0)
        @testset "Zero Time Frame" begin
            result = Fuel_Consumption_Module.integral_for_r(0.0, 5.0) 
            @test result ≈ 0.0 
        end

        # Test 2: Small time frame and small speed
        @testset "Small Time Frame and Speed" begin
            result = Fuel_Consumption_Module.integral_for_r(1.0, 2.0)  
            expected = 0.0625 * 1.0 + 0.001 * (2.0^3) * 1.0 
            @test result ≈ expected atol=1e-6
        end

        # Test 3: Large time frame and higher speed
        @testset "Large Time Frame and Higher Speed" begin
            result = Fuel_Consumption_Module.integral_for_r(10.0, 10.0)  
            expected = 0.0625 * 10.0 + 0.001 * (10.0^3) * 10.0
            @test result ≈ expected atol=1e-6
        end

        # Test 4: Edge case where speed is zero (v_sr = 0)
        @testset "Zero Speed" begin
            result = Fuel_Consumption_Module.integral_for_r(5.0, 0.0)  
            expected = 0.0625 * 5.0  # 
            @test result ≈ expected atol=1e-6 
        end
    end
end