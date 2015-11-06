%Simulation illustrating the type 2 behaviour

%These are optimal paramters
preStretch = 2.5;
nCells = 30;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 40e-3 * preStretch;
electrodeType = ElectrodeTypeEnum.LocallyControlled;

%Define the switching models
rOn = 3.7; rOff = 2.6;
switchingModelLocal = TypeIIModel(rOn, rOff);

tEnd = 10; period = 2;
switchingModelExternal = CyclicSwitchModel(tEnd, period);

%initialises a thread with equally spaced, locally controlled electrodes
thread = Thread.ConstructThreadWithSpacedElectrodes( ...
                preStretch, ...
                cellLengthAtPrestretch, ...
                nCells, ...
                spacingAtPrestretch, ...
                switchingModelLocal, ...
                switchingModelExternal, ...
                GentParams.Koh2012, ...
                @(x)FiberConstrainedElement(x, 1));
 
% thread.RCCircuit.SourceVoltage = 5500;
thread.RCCircuit.Resistance = 1e7;
            
%Uncomment this to plot the thread! (it is currently in prestretch config)
thread.Plot(false);
return

%Make a simulator object and run for 7s
simName = mfilename;
sim = SimulateThread(simName, thread);
sim.RunSim(30);

%View the output
viewer = SimViewer(sim.Name);
close all;

figure
viewer.PlotMaterial;

figure
viewer.PlotGlobal;

figure
viewer.PlotSource;

figure
viewer.PlotStretchRatio;
return;
