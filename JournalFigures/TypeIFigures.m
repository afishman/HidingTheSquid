function [figures, animator] = TypeIFigures

simName = 'TypeIBehaviour_centered';
viewer = SimViewer.LoadReport(simName);
viewer.ExtendStart(-5, true);

figures = [TypeIMaterialFigure(viewer), TypeIGlobalFigure(viewer)];
animator = SimAnimator(viewer);

end
