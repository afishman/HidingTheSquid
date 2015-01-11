%The simulation name
simName = mfilename;

%cell length and spacing defined for the prestretch configuration
preStretch = 2.5;
cellLength = 20e-3 * preStretch;
spacing = 80e-3 * preStretch;

%Two cells are used here
stretchedLength = 2*cellLength + spacing;

%this is the coarsest possible resolution
resolution = cellLength; 

%NOTE: RCCircuit.Default could have been used here, This is for
%illustrative purposes
sourceVoltage = 3459.5;
resistance = 200;
rcCircuit = RCCircuit(resistance, sourceVoltage);

%Construct the thread
thread = Thread(stretchedLength, resolution, preStretch, rcCircuit);

%Define the switching models
rOn = 2; rOff = 4.8;
thread.SwitchingModelLocal = TypeIModel(rOn, rOff);

timeOn = 0; timeOff = 6;
thread.SwitchingModelExternal = StepModel(timeOn, timeOff);

%Add electrodes to the thread
thread.AddElectrode(0, cellLength, ElectrodeTypeEnum.ExternallyControlled);
thread.AddElectrode(cellLength + spacing, cellLength, ElectrodeTypeEnum.LocallyControlled);

%Uncomment this to plot the thread!
% showNodes = true;
% sim.Thread.Plot(showNodes);

%Make a simulator object and run for 10s
sim = SimulateThread(simName, thread);
sim.RunSim(7);

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
