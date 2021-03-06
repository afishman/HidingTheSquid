%Illustration of the Type III Behaviour using 30 cells illustrating complex
%behvaiour

%TODO: automate the creation of optimally spaced threads
preStretch = 2.5;
nCells = 30;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 40e-3 * preStretch;

%Define the switching models
rOn1 = 2.8; rOn2 = 2.9;
rOff1 = 2.6; rOff2 = 3.8;
switchingModelLocal = TypeIIIModel(rOn1, rOn2, rOff1, rOff2);

tOn = 0; tOff = 20;
switchingModelExternal = StepModel(tOn, tOff);

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
       
thread.RCCircuit.Resistance = 1e7;
            
%Uncomment this to plot the thread! (it is currently in prestretch config)
% showNodes = true;
% sim.Thread.Plot(showNodes);

%Make a simulator object and run for 7s
simName = mfilename;
sim = SimulateThread(simName, thread);
sim.RelativeErrorTolerance = 1e-2;
sim.RunSim(20);

%View the output
viewer = SimViewer(sim.Name);
close all;

figure
viewer.PlotMaterial;

figure
viewer.PlotGlobal;
return;
