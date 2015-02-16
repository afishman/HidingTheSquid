%These are optimal paramters
%TODO: automate the creation of optimally spaced threads
preStretch = 2.5;
nCells = 2;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 80e-3 * preStretch;
electrodeType = ElectrodeTypeEnum.LocallyControlled;

%Define the switching models
rOn = 2.2; rOff = 4.7;
%switchingModelLocal = TypeIModel(rOn, rOff);
switchingModelLocal = LocalAlwaysOffModel;

timeOn = 0; timeOff = 10;
switchingModelExternal = StepModel(timeOn, timeOff);
%switchingModelExternal = LocalAlwaysOffModel;

%initialises a thread with equally spaced, locally controlled electrodes
thread = Thread.ConstructThreadWithSpacedElectrodes( ...
    preStretch, ...
    cellLengthAtPrestretch, ...
    nCells, ...
    spacingAtPrestretch, ...
    switchingModelLocal, ...
    switchingModelExternal, ...
    @FiberConstrainedElement);

%Uncomment this to plot the thread! (it is currently in prestretch config)
% showNodes = true;
% sim.Thread.Plot(showNodes);

%Make a simulator object and run for 7s
simName = mfilename;
sim = SimulateThread(simName, thread);
sim.RunSim(7);

%View the output
viewer = SimViewer(sim.Name);
close all;

figure
viewer.PlotMaterial;

figure
viewer.PlotGlobal;

figure
viewer.PlotVoltage;

figure
viewer.PlotDVoltage;

figure
viewer.PlotStretchRatio;
return;
