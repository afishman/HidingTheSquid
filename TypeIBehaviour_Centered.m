%Given spacing and a tail
%clear all
%
preStretch = 2.5;

cellLengthAtPrestretch = 20e-3 * preStretch;
resolution = 50e-3;
tail = 3*resolution;
spacingAtPrestretch = 3*resolution;

interCellSpacing = 50e-3;

%Define the switching models
rOn = 2.4; rOff = 4.25;
switchingModelLocal = TypeIModel(rOn, rOff);
%switchingModelLocal = LocalAlwaysOffModel;

timeOn = 0; timeOff = 300;
switchingModelExternal = StepModel(timeOn, timeOff);
%switchingModelExternal = LocalAlwaysOffModel;

stretchedLength = cellLengthAtPrestretch*2 + spacingAtPrestretch + 2*tail;
elementConstructor = @(x) FiberConstrainedElement(x,1);
thread = Thread(stretchedLength, resolution, preStretch, elementConstructor, GentParams.Koh2012);
thread.SwitchingModelLocal = switchingModelLocal;
thread.SwitchingModelExternal = switchingModelExternal;

%Add electrodes
thread.AddElectrode(tail, cellLengthAtPrestretch, ElectrodeTypeEnum.LocallyControlled);

secondElecrodeStart = tail + cellLengthAtPrestretch + spacingAtPrestretch;
thread.AddElectrode(secondElecrodeStart, cellLengthAtPrestretch, ElectrodeTypeEnum.ExternallyControlled);

%Find the driving voltage
activatedCellStretch = 5;

thread.RCCircuit.SourceVoltage = thread.CalculateDrivingVoltageForStretch(activatedCellStretch);
thread.RCCircuit.Resistance = 1e8;

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
