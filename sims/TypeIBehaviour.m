%These are optimal paramters
%TODO: automate the creation of optimally spaced threads
preStretch = 2.5;
nCells = 4;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 80e-3 * preStretch;
electrodeType = ElectrodeTypeEnum.LocallyControlled;

%Define the switching models
rOn = 2.2; rOff = 4.3;
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

thread.RCCircuit.SourceVoltage = 5500;
thread.RCCircuit.Resistance = 1e7;

thread.Electrodes(2).NextElectrode = [];
for i = length(thread.Electrodes):3
    thread.Electrodes(i)=[];
end

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
