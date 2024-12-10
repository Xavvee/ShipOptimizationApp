module IncludesModule
    include("../models/fuel_consumption.jl")
    using .Fuel_Consumption_Module
    export Fuel_Consumption_Module

    include("../graph/graph.jl")
    using .Graph_Module
    export Graph_Module

    include("../graph/create_graph.jl")
    using .Create_Graph_Module
    export Create_Graph_Module
    
    include("../display/display.jl")
    using .Display_Module
    export Display_Module

    include("../models/field.jl")
    using .Field_Module
    export Field_Module

    include("../simulation/vector_calculations.jl")
    using .Vector_Calculations_Module
    export Vector_Calculations_Module

    include("../graph/paths.jl")
    using .Paths_Module
    export Paths_Module

    include("../models/time_generator.jl")
    using .Time_Generator_Module
    export Time_Generator_Module

    include("../models/ship.jl")
    using .Ship_Module
    export Ship_Module

    include("../simulation/simulation.jl")
    using .Simulation_Module
    export Simulation_Module

    include("../simulation/evolve.jl")
    using .Evoluate_Module
    export Evoluate_Module

    include("../simulation/evolution_algorithm.jl")
    using .Evolution_Algorithm_Module
    export Evolution_Algorithm_Module
    
end