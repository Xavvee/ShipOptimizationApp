module Fuel_Consumption_Module
        
    using QuadGK  # biblioteka do numerycznego całkowania

    # Funkcja obliczająca wartość całki dla danego r przy stałej prędkości v_sr
    function integral_for_r(t_fr, v_sr)
        integrand(t) = 0.0625 + 0.001 * v_sr^3  # v_sr jest stałe w danym przedziale
        result, _ = quadgk(integrand, 0, t_fr)   # całkujemy od 0 do t_fr
        return result
    end

    # # Funkcja obliczająca f_c
    # function calculate_f_c(n_r, t_fr_values, v_sr_values)
    #     f_c = 0.0
    #     for r in 1:(n_r - 1)
    #         f_c += integral_for_r(t_fr_values[r], v_sr_values[r])
    #     end
    #     return f_c
    # end

    # # Przykładowe dane
    # n_r = 5  # liczba przedziałów
    # t_fr_values = [1.0, 2.0, 1.5, 2.5]  # wartości czasu końcowego t_fr dla każdego r
    # v_sr_values = [10.0, 12.0, 15.0, 20.0]  # wartości prędkości v_sr dla każdego r

    # # Obliczamy wartość f_c
    # f_c = calculate_f_c(n_r, t_fr_values, v_sr_values)
    # println("Wartość f_c wynosi: ", f_c)

end