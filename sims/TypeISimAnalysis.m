%clear all
clc

simTime = 100;

%These are optimal paramters
%TODO: automate the creation of optimally spaced threads
preStretch = 2.5;
nCells = 2;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 80e-3 * preStretch;

switchingModelLocal = LocalAlwaysOffModel;
switchingModelExternal = StepModel(0, simTime);

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

for electrode = thread.Electrodes
    electrode.Type = ElectrodeTypeEnum.ExternallyControlled;
end

name = mfilename;
sim = SimulateThread(mfilename, thread);
sim.RunSim(simTime);

close all
thread.Plot