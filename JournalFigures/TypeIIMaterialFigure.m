classdef TypeIIMaterialFigure < SimFigure
    properties
        Name =  'typeIIMaterial';
    end
    
    methods
        function this = TypeIIMaterialFigure(viewer)
            this@SimFigure(viewer);
        end
    
        
        function Generate(this)
            figure
            this.Viewer.PlotMaterial
            xlim([-2, 7])
        end
    end
end

