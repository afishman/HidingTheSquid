function figures = TypeIIIFigures
%TYPEIIFIGURES Summary of this function goes here
%   Detailed explanation goes here
simName = 'TypeIIIBehaviour';
viewer = SimViewer.LoadReport(simName);
%viewer.ExtendStart(-2, true);

figures = [TypeIIIMaterialFigure(viewer), TypeIIIGlobalFigure(viewer), TypeIIICuttleFigure(viewer)];


end

