classdef TypeIGlobalFigure < SimFigure
    properties
        Name =  'typeIGlobal';
    end
    
    methods
        function this = TypeIGlobalFigure(viewer)
            this@SimFigure(viewer);
        end
        
        function Generate(this)
            this.Viewer.PlotGlobal
            ylim([0.5,1.5])
            set(gca, 'YTick', [])
            ylabel('');
        end
    end
end

