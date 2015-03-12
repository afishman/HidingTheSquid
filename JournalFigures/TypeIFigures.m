function figures = TypeIFigures

simName = 'TypeIBehaviour_centered';
viewer = SimViewer.LoadReport(simName);
viewer.ExtendStart(-5);

figures = [TypeIMaterialFigure(viewer), TypeIGlobalFigure(viewer)];

end
