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
            xlim([-2,7])
            set(gca, 'YTick', [])
            ylabel('');
        end
    end
end

