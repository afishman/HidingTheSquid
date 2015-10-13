classdef TypeIIGlobalFigure < SimFigure
    properties
        Name =  'typeIIGlobal';
    end
    
    methods
        function this = TypeIIGlobalFigure(viewer)
            this@SimFigure(viewer);
        end
        
        function Generate(this)
            this.Viewer.PlotGlobal
            xlimits = xlim;
            xlimits(2) = 8.5;
            xlim(xlimits)
        end
    end
end

