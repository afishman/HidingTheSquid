%These are optimal paramters
%TODO: automate the creation of optimally spaced threads
preStretch = 2.5;
nCells = 30;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 40e-3 * preStretch;

%Define the switching models
rOn1 = 2.9; rOn2 = 4.7;
rOff1 = 2.7; rOff2 = 4.9;
switchingModelLocal = TypeIIIModel(rOn1, rOn2, rOff1, rOff2);

tOn = 0; tOff = 1;
switchingModelExternal = StepModel(tOn, tOff);

%NOTE: RCCircuit.Default could have been used here, This is for
%illustrative purposes
resistance = 200;
sourceVoltage = 3459.5;
rcCircuit = RCCircuit(resistance, sourceVoltage);

%initialises a thread with equally spaced, locally controlled electrodes
thread = Thread.ConstructThreadWithSpacedElectrodes( ...
                preStretch, ...
                cellLengthAtPrestretch, ...
                nCells, ...
                spacingAtPrestretch, ...
                switchingModelLocal, ...
                switchingModelExternal, ...
                rcCircuit);
                    
           
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
viewer.PlotSource;

figure
viewer.PlotStretchRatio;
return;
