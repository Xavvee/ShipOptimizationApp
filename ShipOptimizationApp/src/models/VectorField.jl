using Plots
T = 12

x_interval = 24
y_interval = 60
x_amplitude = 1.2
y_amplitude = 2

# Funkcje definiujące składowe wektorów
function vx_custom(x, y, t, T)
    global x_interval, x_amplitude
    modulo_x = x%x_interval
    return x*x_amplitude*modulo_x*sin(2 * π * t / T)
end

function vy_custom(x, y, t, T)
    global y_interval, y_amplitude
    modulo_y = y%y_interval
    return y_amplitude*modulo_y*sin(2 * π * t / T)  
end

# Zakresy dla x, y, t
x_range = 0:2:60
y_range = 0:2:60
t_range = 0:0.5:24

# Generowanie współrzędnych punktów siatki
grid_points = collect(Iterators.product(x_range, y_range))

# Inicjalizacja listy przechowującej wektory
quiver_plots = []

# Dla każdego punktu na siatce obliczamy wektor
for t in t_range
    vx_values = [vx_custom(x, y, t, T) for (x, y) in grid_points]
    vy_values = [vy_custom(x, y, t, T) for (x, y) in grid_points]
    
    quiver_plot = plot(xlim=(0, 60), ylim=(0, 60), xlabel="x", ylabel="y", title="Pole Wektorowe dla t = $t")
    quiver!(quiver_plot, [p[1] for p in grid_points], [p[2] for p in grid_points], quiver=(vx_values, vy_values))
    
    push!(quiver_plots, quiver_plot)
end

# Wyświetlenie animacji
anim = @animate for i in 1:length(quiver_plots)
    plot(quiver_plots[i])
end

gif(anim, "vector_field.gif", fps = 3)