%The filename
simName = mfilename;

preStretch = 2.5;
cellLength = 20e-3 * preStretch;
spacing = 80e-3 * preStretch;

%Two cells are used here
stretchedLength = 2*cellLength + spacing;

%this is the coarsest possible resolution
resolution = cellLength; 

%NOTE: RCCircuit.Default could have been used here
sourceVoltage = 3459.5;
resistance = 41400000;
rcCircuit = RCCircuit(resistance, sourceVoltage);

%Switching Model
rOn = 2; rOff = 4.8;
localSwitchingModel = TypeIModel(rOn, rOff);

%External Switch
timeOn = 0; timeOff = 5;
externalSwitchingModel = StepModel(timeOn, timeOff);

thread = Thread(stretchedLength, resolution, preStretch, rcCircuit);
thread.SwitchingModelLocal = LocalAlwaysOffModel;
thread.SwitchingModelExternal = externalSwitchingModel;

%Add electrodes to the thread
thread.AddElectrode(0, cellLength, ElectrodeTypeEnum.ExternallyControlled);
thread.AddElectrode(cellLength + spacing, cellLength, ElectrodeTypeEnum.ExternallyControlled);



%Make a simulator object
sim = SimulateThread(simName, thread);


%plot it!
% showNodes = true;
% sim.Thread.Plot(showNodes);

sim.RunSim(10);

viewer = SimViewer('sawOsc');
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
