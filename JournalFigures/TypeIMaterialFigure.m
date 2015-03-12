classdef TypeIMaterialFigure < SimFigure
    properties
        Name =  'typeIMaterial';
    end
    
    methods
        function this = TypeIMaterialFigure(viewer)
            this@SimFigure(viewer);
        end
    
        
        function Generate(this)
            figure
            this.Viewer.PlotMaterial
            ylim([0.12, 0.23])
        end
    end
end

