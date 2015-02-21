%These are optimal paramters
%TODO: automate the creation of optimally spaced threads
preStretch = 2.5;
nCells = 6;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 80e-3 * preStretch;
electrodeType = ElectrodeTypeEnum.LocallyControlled;

%Define the switching models
rOn = 2.4; rOff = 4.5;
switchingModelLocal = TypeIModel(rOn, rOff);
%switchingModelLocal = LocalAlwaysOffModel;

timeOn = 0; timeOff = 300;
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
    GentParams.Koh2012, ...
    @(x)FiberConstrainedElement(x,1));

thread.Electrodes(6) = [];
thread.Electrodes(5) = [];
thread.Electrodes(3).Type = ElectrodeTypeEnum.ExternallyControlled;
thread.Electrodes(4).Type = ElectrodeTypeEnum.LocallyControlled;
thread.Electrodes(2) = [];
thread.Electrodes(1) = [];

thread.RCCircuit.Resistance = 1e8;
return
%Uncomment this to plot the thread! (it is currently in prestretch config)
% showNodes = true;
% sim.Thread.Plot(showNodes);

%Make a simulator object and run for 7s
simName = mfilename;
sim = SimulateThread(simName, thread);
sim.RunSim(timeOff*1.2);

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
