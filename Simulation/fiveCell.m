

clear all
close all

preStretch = 3;
cellLengthAtPrestretch = 10;
resolution = 10;
passiveMembraneSectionLength = 10;
stretchedLength = 90;
elementConstructor = @(x) FiberConstrainedElement(x);

thread = Thread(stretchedLength, resolution, preStretch, elementConstructor, GentParams.Koh2012);

tEnd = 1; 
period = 2;
thread.SwitchingModelExternal = StepModel(0, 10);

%thread.Plot()
thread.RCCircuit.SourceVoltage = 2500;
thread.RCCircuit.Resistance = 1000;

for i=0:4
    thread.AddElectrode(i*2*cellLengthAtPrestretch, cellLengthAtPrestretch, ElectrodeTypeEnum.ExternallyControlled);
    break;
end




sim = SimulateThread(mfilename, thread);
sim.RunSim(10);

viewer = SimViewer(sim.Name);

figure
viewer.PlotMaterial;
