module Fuel_Consumption_Module

    using QuadGK

    function integral_for_r(t_fr, v_sr)
        integrand(t) = 0.0625 + 0.001 * v_sr^3 
        result, _ = quadgk(integrand, 0, t_fr)
        return result
    end

end