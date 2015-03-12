

viewer = SimViewer.LoadReport('TypeIBehaviour_centered');
viewer.ExtendStart(-5);

figure
viewer.PlotMaterial
ylim([0.12, 0.23])

figure
viewer.PlotGlobal
ylim([0.5,1.5])
set(gca, 'YTick', [])
ylabel('');