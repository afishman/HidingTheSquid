viewer = SimViewer.LoadReport('TypeIIBehaviour');
ani = SimAnimator(viewer);
ani.RenderToMp4;

simName = 'TypeIIIBehaviour';
viewer = SimViewer.LoadReport(simName);
ani = SimAnimator(viewer);
ani.RenderToMp4;

