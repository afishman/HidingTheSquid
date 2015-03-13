classdef TypeIICuttleFigure < SimFigure
    properties
        Name =  'typeIICuttlefish';
    end
    
    methods
        function this = TypeIICuttleFigure(viewer)
            this@SimFigure(viewer);
        end
    
        function Generate(this)
            animator = SimAnimator(this.Viewer);
            animator.PlotCuttleSet([0, 0.5, 1, 1.5])
        end
    end
end

