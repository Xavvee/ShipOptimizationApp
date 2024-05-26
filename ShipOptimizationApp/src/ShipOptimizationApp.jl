module ShipOptimizationApp

using Gtk

include("gui/MainWindow.jl")
using .MainWindow


function main()
    println("Hello world!")
    window = MainWindow.createMainWindow()
    showall(window)
end

end

ShipOptimizationApp.main()