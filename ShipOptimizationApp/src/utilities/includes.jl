module IncludesModule

    include("../graph/graph.jl")
    using .Graph_Module
    export Graph_Module

    include("../graph/create_graph.jl")
    using .Create_Graph_Module
    export Create_Graph_Module
    
    include("../utilities/display.jl")
    using .Display_Module
    export Display_Module

    include("../models/field.jl")
    using .Field_Module
    export Field_Module

    include("../utilities/utils.jl")
    using .Utils_Module
    export Utils_Module

    include("../graph/paths.jl")
    using .Paths_Module
    export Paths_Module

    include("../utilities/time_generator.jl")
    using .Time_Generator_Module
    export Time_Generator_Module

    include("../models/ship.jl")
    using .Ship_Module
    export Ship_Module
    

    include("../simulation/simulation.jl")
    using .Simulation_Module
    export Simulation_Module

    include("../simulation/evoluate.jl")
    using .Evoluate_Module
    export Evoluate_Module
    
end