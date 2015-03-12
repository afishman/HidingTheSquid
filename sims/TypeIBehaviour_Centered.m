%Given spacing and a tail
%clear all
%
preStretch = 2.5;

cellLengthAtPrestretch = 20e-3 * 2.5;
resolution = 50e-3;
tail = 3*resolution;

%Define the switching models
rOn = 2.8; rOff = 4.2;
switchingModelLocal = TypeIModel(rOn, rOff);
%switchingModelLocal = LocalAlwaysOffModel;

timeOff = 25;
switchingModelExternal = StepModel(0, timeOff);
%switchingModelExternal = LocalAlwaysOffModel;

stretchedLength = cellLengthAtPrestretch + 2*tail;
elementConstructor = @(x) FiberConstrainedElement(x,1);
thread = Thread(stretchedLength, resolution, preStretch, elementConstructor, GentParams.Koh2012);
thread.SwitchingModelLocal = switchingModelLocal;
thread.SwitchingModelExternal = switchingModelExternal;
thread.SwitchAllOff = timeOff;

%Add electrodes
thread.AddElectrode(tail, cellLengthAtPrestretch, ElectrodeTypeEnum.LocallyControlled);

%Find the driving voltage
activatedCellStretch = 5;
thread.RCCircuit.SourceVoltage = thread.DrivingVoltageForStretch(activatedCellStretch);
thread.RCCircuit.Resistance = 1e8;

close all
thread.Plot


%Make a simulator object and run for 7s
simName = mfilename;
sim = SimulateThread(simName, thread);
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
