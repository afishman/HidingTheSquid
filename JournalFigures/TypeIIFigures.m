function figures = TypeIIFigures
%TYPEIIFIGURES Summary of this function goes here
%   Detailed explanation goes here
simName = 'TypeIIBehaviour';
viewer = SimViewer.LoadReport(simName);
viewer.ExtendStart(-2);

figures = [TypeIIMaterialFigure(viewer), TypeIIGlobalFigure(viewer)];


end

