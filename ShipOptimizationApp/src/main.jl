include("display.jl")
using .Display

include("simulation.jl")
using .Simulation

include("evoluate.jl")
using .Evoluate_Module

using Plots
using Plots.PlotMeasures

# Zakresy dla x, y, t

x_range = Simulation.create_custom_range(-10, 4, 30)
y_range = Simulation.create_custom_range(-10, 2, 30)
t_range = Simulation.create_custom_range(0, 0.5, 23.5)

T = 24

# odpalać na terminalu `julia -t 4`, sprawdazć czy wyświetli odpowiednio - `Threads.nthreads()`
ships, g, node_positions = Simulation.simulate(T)
ships = Simulation.quick_select(ships)
for ship in ships
    println("$(ship.path) -> $(ship.finish_time)")
end

better_ships = Evoluate_Module.evoluate(ships, g, node_positions, 10)

sorted_ships = sort(better_ships, by = ship -> ship.finish_time, rev = true)

println("------------------")
for ship in sorted_ships
    println("Fixed: $(ship.path) -> $(ship.finish_time)")
end
# quiver_plots = Simulation.simulate_multiple_ships(x_range, y_range, T)

# # Wyświetlenie animacji

# anim = Display.display_simulation(quiver_plots)


# gif(anim, "vector_field.gif", fps=3)

