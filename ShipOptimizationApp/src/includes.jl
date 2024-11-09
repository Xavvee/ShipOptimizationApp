module IncludesModule

    include("graph.jl")
    using .Graph_Module
    export Graph_Module

    include("create_graph.jl")
    using .Create_Graph_Module
    export Create_Graph_Module
    
    include("display.jl")
    using .Display_Module
    export Display_Module

    include("field.jl")
    using .Field_Module
    export Field_Module

    include("utils.jl")
    using .Utils_Module
    export Utils_Module

    include("paths.jl")
    using .Paths_Module
    export Paths_Module

    include("time_generator.jl")
    using .Time_Generator_Module
    export Time_Generator_Module

    include("ship.jl")
    using .Ship_Module
    export Ship_Module
    

    include("simulation.jl")
    using .Simulation_Module
    export Simulation_Module

    include("evoluate.jl")
    using .Evoluate_Module
    export Evoluate_Module

    
end