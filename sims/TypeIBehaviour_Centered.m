%Given spacing and a tail
clear all

%TODO: Write decription here

preStretch = 2.5;
cellLengthAtPrestretch = 20e-3 * 2.5;
resolution = 50e-3;

%150 mm on each side
passiveMembraneSectionLength = 3*resolution;

%Construct a thread
stretchedLength = cellLengthAtPrestretch + 2*passiveMembraneSectionLength;
elementConstructor = @(x) FiberConstrainedElement(x,1);
thread = Thread(stretchedLength, resolution, preStretch, elementConstructor, GentParams.Koh2012);

%Define the switching models
rOn = 2.9; rOff = 4.2;
switchingModelLocal = TypeIModel(rOn, rOff);

thread.SwitchingModelLocal = switchingModelLocal;
thread.SwitchingModelExternal = ExternalAlwaysOffModel;

%Deactivate all cells after a perscribed amount of time 
timeOff = 10;
thread.SwitchAllOff = timeOff;

%Find the driving voltage
activatedCellStretch = 5;
thread.RCCircuit.SourceVoltage = 5600;
%thread.RCCircuit.SourceVoltage = thread.DrivingVoltageForStretch(activatedCellStretch);
thread.RCCircuit.Resistance = 1e8;

%Add electrodes
thread.AddElectrode(passiveMembraneSectionLength, cellLengthAtPrestretch, ElectrodeTypeEnum.LocallyControlled);

%Make a simulator and run it
sim = SimulateThread(mfilename, thread);
sim.RunSim(timeOff*1.2);

%View the output
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
