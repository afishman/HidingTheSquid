function figures = TypeIIFigures
%TYPEIIFIGURES Summary of this function goes here
%   Detailed explanation goes here
simName = 'TypeIIBehaviour';
viewer = SimViewer.LoadReport(simName);
viewer.ExtendStart(-2, true);

figures = [TypeIIMaterialFigure(viewer), TypeIIGlobalFigure(viewer), TypeIICuttleFigure(viewer)];


end

