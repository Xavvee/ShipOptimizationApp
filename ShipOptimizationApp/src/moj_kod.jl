using Plots
T = 24


# Funkcje definiujące składowe wektorów
function vx_custom(x, y, t, T)
    return (x-30)/30*sin(2 * π *t/T)+(y-40)/60
end

function vy_custom(x, y, t, T)
    return (0.3*x+0.1*y) *cos(2 * π *t/T)
end

# Zakresy dla x, y, t
x_range = -10:1:10
y_range = -10:1:10
t_range = 0:0.5:24

# Generowanie współrzędnych punktów siatki
grid_points = collect(Iterators.product(x_range, y_range))

# Inicjalizacja listy przechowującej wektory
quiver_plots = []

# Dla każdego punktu na siatce obliczamy wektor
for t in t_range
    vx_values = [vx_custom(x, y, t, T) for (x, y) in grid_points]
    vy_values = [vy_custom(x, y, t, T) for (x, y) in grid_points]
    
    quiver_plot = plot(xlim=(-10,10), ylim=(-10,10), xlabel="x", ylabel="y", title="Pole Wektorowe dla t = $t")
    quiver!(quiver_plot, [p[1] for p in grid_points], [p[2] for p in grid_points], quiver=(vx_values, vy_values))
    
    push!(quiver_plots, quiver_plot)
end

# Wyświetlenie animacji
anim = @animate for i in 1:length(quiver_plots)
    plot(quiver_plots[i])
end

gif(anim, "vector_field.gif", fps = 3)