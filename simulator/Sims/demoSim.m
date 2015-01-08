clearvars
clc

%The filename
simName = mfilename;

%form a thread of material
stretchedLength = 1;
resolution = 0.5; %Length of an element in the prestretched configuration
prestretch = 2;

%NOTE: RCCircuit.Default is also defined
voltage = 1000;
resistance = 100;
rcCircuit = RCCircuit(voltage, resistance);

%Make a thread
thread = Thread(stretchedLength, resolution, prestretch, rcCircuit);
thread.SwitchingModelLocal = StepModel(0, 10);

%Make a simulator object
obj = SimulateThread(simName, thread);

%Add electrodes to the simulator
obj.SimThread.AddElectrode(0, resolution, ElectrodeTypeEnum.LocallyControlled);
obj.SimThread.AddElectrode(resolution, resolution, ElectrodeTypeEnum.ExternallyControlled);

%plot it!
showNodes = true;
obj.SimThread.Plot(showNodes);

return;

%Set the name
obj.name=filename;

%Set the activation function
obj.actiFun = @(t)actiFunBin(t, 1000);

runSim(obj,1700);