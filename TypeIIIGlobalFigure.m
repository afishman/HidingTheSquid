classdef TypeIIIGlobalFigure < SimFigure
    properties
        Name =  'typeIIIGlobal';
    end
    
    methods
        function this = TypeIIIGlobalFigure(viewer)
            this@SimFigure(viewer);
        end
        
        function Generate(this)
            this.Viewer.PlotGlobal
        end
    end
end

