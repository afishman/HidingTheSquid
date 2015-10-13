classdef TypeIIIMaterialFigure < SimFigure
    properties
        Name =  'typeIIIMaterial';
    end
    
    methods
        function this = TypeIIIMaterialFigure(viewer)
            this@SimFigure(viewer);
        end
    
        function Generate(this)
            figure
            this.Viewer.PlotMaterial
        end
    end
end

