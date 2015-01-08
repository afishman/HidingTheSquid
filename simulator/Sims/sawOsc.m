clearvars
clc

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
voltage = 3459.5;
resistance = 500;
rcCircuit = RCCircuit(voltage, resistance);

%Make a thread
rOn = 2; rOff = 4.8;
localSwitchingModel = TypeIModel(rOn, rOff);

timeOn = 0; timeOff = 10;
externalSwitchingModel = StepModel(timeOn, timeOff);

thread = Thread(stretchedLength, resolution, preStretch, rcCircuit);
thread.SwitchingModelLocal = LocalAlwaysOffModel;
thread.SwitchingModelExternal = StepModel(0,1);

%Add electrodes to the thread
thread.AddElectrode(0, cellLength, ElectrodeTypeEnum.ExternallyControlled);
thread.AddElectrode(cellLength + spacing, cellLength, ElectrodeTypeEnum.LocallyControlled);



%Make a simulator object
sim = SimulateThread(simName, thread);


%plot it!
showNodes = true;
sim.Thread.Plot(showNodes);

sim.RunSim(10);

return;