using Test

include("../src/models/ship.jl")
using .Ship_Module

@testset "Ship_Module Tests" begin

    @testset "Ship Initialization" begin
        ship = Ship_Module.Ship(0.0, 0.0, 10.0, 10.0, 5.0, [1, 2, 3], 0.1)

        @test ship.position_x == 0.0
        @test ship.position_y == 0.0
        @test ship.finish_x == 10.0
        @test ship.finish_y == 10.0
        @test ship.max_speed == 5.0
        @test ship.field_speed_x == 0.0
        @test ship.field_speed_y == 0.0
        @test ship.ship_speed_x == 0.0
        @test ship.ship_speed_y == 0.0
        @test ship.resultant_speed_x == 0.0
        @test ship.resultant_speed_y == 0.0
        @test ship.path == [1, 2, 3]
        @test ship.current_node_index == 1
        @test ship.finish_time == 0.0
        @test ship.time_step == 0.1
        @test ship.continuous_path == []
        @test ship.fuel_consumption == 0.0
    end

    @testset "move_ship! Function" begin
        ship = Ship_Module.Ship(0.0, 0.0, 10.0, 10.0, 5.0, [1, 2, 3], 0.1)
        ship.resultant_speed_x = 2.0
        ship.resultant_speed_y = 3.0

        Ship_Module. move_ship!(ship)

        @test ship.position_x ≈ 0.2 
        @test ship.position_y ≈ 0.3
    end

    @testset "update_field_speed! Function" begin
        ship = Ship_Module.Ship(0.0, 0.0, 10.0, 10.0, 5.0, [1, 2, 3], 0.1)
        Ship_Module.update_field_speed!(ship, 1.5, 2.5)

        @test ship.field_speed_x == 1.5
        @test ship.field_speed_y == 2.5
    end

    @testset "update_ship_speed! Function" begin
        ship = Ship_Module.Ship(0.0, 0.0, 10.0, 10.0, 5.0, [1, 2, 3], 0.1)
        Ship_Module.update_ship_speed!(ship, 4.0, 3.0)

        @test ship.ship_speed_x == 4.0
        @test ship.ship_speed_y == 3.0
    end

    @testset "update_resultant_ship_speed! Function" begin
        ship = Ship_Module.Ship(0.0, 0.0, 10.0, 10.0, 5.0, [1, 2, 3], 0.1)
        Ship_Module.update_field_speed!(ship, 1.0, 2.0)
        Ship_Module.update_ship_speed!(ship, 3.0, 4.0)

        Ship_Module.update_resultant_ship_speed!(ship)

        @test ship.resultant_speed_x == 4.0 
        @test ship.resultant_speed_y == 6.0 
    end
end