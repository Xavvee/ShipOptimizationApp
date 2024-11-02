include("display.jl")
using .Display

include("simulation.jl")
using .Simulation

using Plots
using Plots.PlotMeasures

# Zakresy dla x, y, t

x_range = Simulation.create_custom_range(-10, 4, 30)
y_range = Simulation.create_custom_range(-10, 2, 30)
t_range = Simulation.create_custom_range(0, 0.5, 23.5)

T = 24

# odpalać na terminalu `julia -t 4`, sprawdazć czy wyświetli odpowiednio - `Threads.nthreads()`
ships = Simulation.simulate(T)
ships = Simulation.quick_select(ships)
for ship in ships
    println("$(ship.path) -> $(ship.finish_time)")
end

# quiver_plots = Simulation.simulate_multiple_ships(x_range, y_range, T)

# # Wyświetlenie animacji

# anim = Display.display_simulation(quiver_plots)


# gif(anim, "vector_field.gif", fps=3)

