%Given spacing and a tail
%clear all
%
preStretch = 2.5;

cellLengthAtPrestretch = 20e-3 * 2.5;
resolution = 50e-3;
tail = 8*resolution;
spacingAtPrestretch = resolution;

interCellSpacing = 50e-3;

%Define the switching models
rOn = 2.8; rOff = 4.25;
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

%thread.AddElectrode(0*cellLengthAtPrestretch, cellLengthAtPrestretch, ElectrodeTypeEnum.ExternallyControlled);
%thread.AddElectrode(1*cellLengthAtPrestretch, cellLengthAtPrestretch, ElectrodeTypeEnum.ExternallyControlled);
%thread.AddElectrode(2*cellLengthAtPrestretch, cellLengthAtPrestretch, ElectrodeTypeEnum.ExternallyControlled);


secondElecrodeStart = tail + cellLengthAtPrestretch + spacingAtPrestretch;
%thread.AddElectrode(0, cellLengthAtPrestretch, ElectrodeTypeEnum.ExternallyControlled);
thread.AddElectrode(secondElecrodeStart, cellLengthAtPrestretch, ElectrodeTypeEnum.LocallyControlled);

%Find the driving voltage
activatedCellStretch = 5;
thread.RCCircuit.SourceVoltage = thread.DrivingVoltageForStretch(activatedCellStretch);
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
