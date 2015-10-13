classdef TypeIIICuttleFigure < SimFigure
    properties
        Name =  'typeIIICuttlefish';
    end
    
    methods
        function this = TypeIIICuttleFigure(viewer)
            this@SimFigure(viewer);
        end
    
        function Generate(this)
            animator = SimAnimator(this.Viewer);
            animator.PlotCuttleSet([0, 0.4, 0.8, 1.25])
        end
    end
end

