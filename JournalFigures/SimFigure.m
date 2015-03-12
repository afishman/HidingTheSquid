classdef SimFigure < JournalFigure 
    %SIMFIGURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Viewer;
    end
    
    methods
        function this = SimFigure(viewer)
            this.Viewer = viewer;
        end
    end
    
end

