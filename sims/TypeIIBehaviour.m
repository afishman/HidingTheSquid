%These are optimal paramters
%TODO: automate the creation of optimally spaced threads
preStretch = 2.5;
nCells = 5;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 40e-3 * preStretch;
electrodeType = ElectrodeTypeEnum.LocallyControlled;

%Define the switching models
rOn = 3.7; rOff = 2.6;
switchingModelLocal = TypeIIModel(rOn, rOff);

tEnd = 5.5; period = 1;
switchingModelExternal = CyclicSwitchModel(tEnd, period);

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
            
%Set the first electrode to be externally controlled
thread.StartElectrode.Type = ElectrodeTypeEnum.ExternallyControlled;

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
