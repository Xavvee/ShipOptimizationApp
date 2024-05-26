module MainWindow

using Gtk

function createMainWindow()
    builder = GtkBuilder(filename="../assets/ShipOptimizationApp.glade")


    window = builder["window1"]
    button = builder["button1"]

    signal_connect(button, "clicked") do widget
        println("Hello, world!")
    end

    return window

end

end