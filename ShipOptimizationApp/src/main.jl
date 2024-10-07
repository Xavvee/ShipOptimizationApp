include("utils.jl")
using .Utils

include("field.jl")
using .Field

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

quiver_plots = Simulation.simulate(x_range, y_range, T)

# Wyświetlenie animacji

Display.display(quiver_plots)
