module Ship_Module

    mutable struct Ship
        position_x::Float64
        position_y::Float64
        finish_x::Float64
        finish_y::Float64
        max_speed::Float64

        field_speed_x::Float64
        field_speed_y::Float64
        ship_speed_x::Float64
        ship_speed_y::Float64
        resultant_speed_x::Float64
        resultant_speed_y::Float64

        function Ship(position_x::Float64, position_y::Float64, finish_x::Float64, finish_y::Float64, max_speed::Float64)
            new(position_x, position_y, finish_x, finish_y, max_speed, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
    end

    # Aktualizacja pozycji statku na podstawie składowych prędkości wypadkowej
    function move!(ship::Ship)
        ship.position_x += ship.resultant_speed_x
        ship.position_y += ship.resultant_speed_y
    end

    # Aktualizacja prędkości pola
    function update_field_speed!(ship::Ship, vx_field::Float64, vy_field::Float64)
        ship.field_speed_x = vx_field
        ship.field_speed_y = vy_field
    end

    # Aktualizacja prędkości statku (kierunek, którym statek chce podążać)
    function update_ship_speed!(ship::Ship, ship_speed_x::Float64, ship_speed_y::Float64)
        ship.ship_speed_x = ship_speed_x
        ship.ship_speed_y = ship_speed_y
    end

    # Aktualizacja prędkości wypadkowej
    function update_resultant_speed!(ship::Ship)
        ship.resultant_speed_x = ship.field_speed_x + ship.ship_speed_x
        ship.resultant_speed_y = ship.field_speed_y + ship.ship_speed_y
    end

end
