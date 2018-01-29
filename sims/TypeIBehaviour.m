%Example illustration of the Type I Behaviour. 
%A single cell in centered about a length of passive membrane. 
%The thresholds are chosen such that rOn is above pre stretch,
% and rOff are is less than steady state stretch
clear all

preStretch = 2.5;

%50mm at prestretch
cellLengthAtPrestretch = 20e-3 * 2.5;

%Coarsest possible resolution
resolution = 50e-3;

%150 mm on each side
passiveMembraneSectionLength = 3*resolution;

%Construct a thread
stretchedLength = cellLengthAtPrestretch + 2*passiveMembraneSectionLength;
elementConstructor = @(x) FiberConstrainedElement(x);
thread = Thread(stretchedLength, resolution, preStretch, elementConstructor, GentParams.Koh2012);

%2.9 > prestretch; 4.2 < steady state stretch
thread.SwitchingModelLocal = TypeIModel(2.9, 4.2);

%Not required for this sim
thread.SwitchingModelExternal = ExternalAlwaysOffModel;

%Deactivate all cells after a perscribed amount of time
thread.SwitchAllOff = 10;

%Find the driving voltage
activatedCellStretch = 5;
thread.RCCircuit.SourceVoltage = 5600;
thread.RCCircuit.Resistance = 1e8;

%Add electrodes
thread.AddElectrode(passiveMembraneSectionLength, cellLengthAtPrestretch, ElectrodeTypeEnum.LocallyControlled);

%Make a simulator and run it
sim = SimulateThread(mfilename, thread);
sim.RunSim(thread.SwitchAllOff*1.2);

%View the output
viewer = SimViewer(sim.Name);
close all;

figure
viewer.PlotMaterial;

figure
viewer.PlotGlobal;