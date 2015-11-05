preStretch = 2.5;

stretchedLength = 140e-3 * preStretch;
resolution = 50e-3;
elementConstructor = @(x) FiberConstrainedElement(x, 1);
gentParams = GentParams.Koh2012;

thread = Thread(stretchedLength, resolution, preStretch, elementConstructor, gentParams);

thread.SwitchingModelLocal = TypeIModel(2.9, 4.2);

%make the approach an actuation stretch ratio of 5
thread.RCCircuit = RCCircuit(10e6, thread.DrivingVoltageForStretch(5));

thread.AddElectrode(150e-3, 50e-3, ElectrodeTypeEnum.LocallyControlled);

%Make a simulator object and run for 7s
sim = SimulateThread(mfilename, thread);
sim.RunSim(30);

close all
thread.Plot;

return

%These are optimal paramters
%TODO: automate the creation of optimally spaced threads
preStretch = 2.5;
nCells = 4;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 80e-3 * preStretch;
electrodeType = ElectrodeTypeEnum.LocallyControlled;

%Define the switching models
rOn = 2.2; rOff = 4.3;
switchingModelLocal = TypeIModel(rOn, rOff);
%switchingModelLocal = LocalAlwaysOffModel;

timeOn = 0; timeOff = 300;
switchingModelExternal = StepModel(timeOn, timeOff);
%switchingModelExternal = LocalAlwaysOffModel;

%initialises a thread with equally spaced, locally controlled electrodes
thread = Thread.ConstructThreadWithSpacedElectrodes( ...
    preStretch, ...
    cellLengthAtPrestretch, ...
    nCells, ...
    spacingAtPrestretch, ...
    switchingModelLocal, ...
    switchingModelExternal, ...
    GentParams.Koh2012, ...
    @(x)FiberConstrainedElement(x,1));

thread.RCCircuit.SourceVoltage = 5500;
thread.RCCircuit.Resistance = 1e7;

thread.Electrodes(2).NextElectrode = [];
for i = length(thread.Electrodes):3
    thread.Electrodes(i)=[];
end

%Make a simulator object and run for 7s
simName = mfilename;
sim = SimulateThread(simName, thread);


%Uncomment this to plot the thread! (it is currently in prestretch config)
showNodes = true;
sim.Thread.Plot(showNodes);

return

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
