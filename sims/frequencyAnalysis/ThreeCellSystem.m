function ThreeCellSystem(tau)

%These are optimal paramters
%TODO: automate the creation of optimally spaced threads
preStretch = 2.5;
nCells = 2;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 80e-3 * preStretch;
electrodeType = ElectrodeTypeEnum.LocallyControlled;

%Define the switching models
rOn = 2.2; rOff = 4.7;
switchingModelLocal = TypeIModel(rOn, rOff);
switchingModelLocal = LocalAlwaysOffModel;

timeOn = 0; timeOff = 6;
switchingModelExternal = StepModel(timeOn, timeOff);
%switchingModelExternal = LocalAlwaysOffModel;

%NOTE: RCCircuit.Default could have been used here, This is for
%illustrative purposes
resistance = 500;
sourceVoltage = 4500;
rcCircuit = RCCircuit(resistance, sourceVoltage);

%initialises a thread with equally spaced, locally controlled electrodes
thread = Thread.ConstructThreadWithSpacedElectrodes( ...
                preStretch, ...
                cellLengthAtPrestretch, ...
                nCells, ...
                spacingAtPrestretch, ...
                switchingModelLocal, ...
                switchingModelExternal, ...
                rcCircuit);
            
%Set the first electrode to be externally controlled
thread.StartElectrode.Type = ElectrodeTypeEnum.ExternallyControlled;
thread.StartElectrode.NextElectrode.Type = ElectrodeTypeEnum.ExternallyControlled;
%Uncomment this to plot the thread! (it is currently in prestretch config)
% showNodes = true;
% sim.Thread.Plot(showNodes);

%Make a simulator object and run for 7s
simName = mfilename;
sim = SimulateThread(simName, thread);
sim.RunSim(7);
return;
