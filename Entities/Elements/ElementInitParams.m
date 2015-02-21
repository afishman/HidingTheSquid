classdef ElementInitParams
    properties
        StartVertex;
        EndVertex;
        PreStretch;
        NaturalLength;
        MaterialProperties;
        GentParams;
    end
    
    
    methods
        function this = ElementInitParams( ...
                startVertex, ...
                endVertex, ...
                preStretch, ...
                naturalLength, ...
                materialProperties, ...
                gentParams)
            
            this.StartVertex = startVertex;
            this.EndVertex = endVertex;
            this.PreStretch = preStretch;
            this.NaturalLength = naturalLength;
            this.MaterialProperties = materialProperties;
            this.GentParams = gentParams;
        end
    end
end