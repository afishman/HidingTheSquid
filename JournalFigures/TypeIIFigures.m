function figures = TypeIIFigures
%TYPEIIFIGURES Summary of this function goes here
%   Detailed explanation goes here
simName = 'TypeIIBehaviour';
viewer = SimViewer.LoadReport(simName);

extension = 0.5;
viewer.ExtendStart(-extension, true);

figures = [TypeIIMaterialFigure(viewer), TypeIIGlobalFigure(viewer), TypeIICuttleFigure(viewer)];


end

