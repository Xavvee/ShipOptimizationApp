module Display

using Plots
using Plots.PlotMeasures

    
function display_simulation(quiver_plots)
    anim = @animate for i in eachindex(quiver_plots)
        plot(quiver_plots[i])
    end
    return anim    
end

end