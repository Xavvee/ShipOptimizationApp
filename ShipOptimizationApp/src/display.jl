module Display
using Plots
using Plots.PlotMeasures

    
function display_simulation(quiver_plots)
    anim = @animate for i in eachindex(quiver_plots)
        plot(quiver_plots[i])
    end

    gif(anim, "vector_field.gif", fps=3)

end


end