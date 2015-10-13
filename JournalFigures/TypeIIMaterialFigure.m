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
            xlimits = xlim;
            xlimits(2) = 8.5;
            xlim(xlimits)
        end
    end
end

