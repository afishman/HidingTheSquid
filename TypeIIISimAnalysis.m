function TypeIIISimAnalysis()

len=20;


sim = CreateSimSS(true, [1,0,0], [1,0,0]);
sim.Name = 'rOnLower';
sim.RunSim(len);
% 
% sim = CreateSimSS(true, [1,1,0], [1,1,1]);
% sim.Name = 'rOffUpper';
% sim.RunSim(len);
% 
% sim = CreateSimSS(true, [1,1,1], [1,1,0]);
% sim.Name = 'rOnUpper';
% sim.RunSim(len);
% 
% sim = CreateSimSS(true, [1,1,0], [1,0,0]);
% sim.Name = 'rOffLower';
% sim.RunSim(len);

% sim = CreateSim(30);
% sim.RunSim(len);

% SimulateThread.ContinueSim('TypeIIISimAnalysis_30cells', len);
%
% sim = CreateSim(29);
% sim.RunSim(len);
%
% sim = CreateSim(28);
% sim.RunSim(len);

end

function sim = CreateSimSS(otherCellsActive, ssArrangement, currStateArrangement)
ssArrangement = sort(ssArrangement);
currStateArrangement = sort(currStateArrangement);

if(otherCellsActive)
    nCellsActive = 27 + sum(ssArrangement);
else
    nCellsActive = sum(ssArrangement);
end




sim = CreateSim(nCellsActive);

[activeStretch, passiveStretch] = sim.Thread.CalculateSteadyStateStretches(nCellsActive);

nBlocksToActivate = sim.Thread.BlocksPerCell*nCellsActive;
count=0;

element = sim.Thread.StartElement;
while(~isempty(element))
    
    if(~isempty(element.RCCircuit) && count<nBlocksToActivate)
        element.SetStretchRatio(activeStretch)
        element.Voltage = element.RCCircuit.SourceVoltage;
        count = count+1;
        
    else
        element.SetStretchRatio(passiveStretch)
    end
    
    element = element.NextElement;
end

if otherCellsActive
    type = ElectrodeTypeEnum.ExternallyControlled;
else
    type = ElectrodeTypeEnum.LocallyControlled;
end

for electrode = sim.Thread.Electrodes
    electrode.Type = type;
end

currElectrode = sim.Thread.StartElectrode;
for state = currStateArrangement
    if(state)
        currElectrode.Type = ElectrodeTypeEnum.ExternallyControlled;
    else
        currElectrode.Type = ElectrodeTypeEnum.LocallyControlled;
    end
    currElectrode = currElectrode.NextElectrode;
end

close all
sim.Thread.Plot;
error(';')


end

function sim = CreateSim(nCellsActive)

%These are optimal paramters
%TODO: automate the creation of optimally spaced threads
preStretch = 2.5;
nCells = 30;
cellLengthAtPrestretch = 20e-3 * preStretch;
spacingAtPrestretch = 40e-3 * preStretch;

tOn = 0; tOff = 200;
switchingModelExternal = StepModel(tOn, tOff);
switchingModelLocal = LocalAlwaysOffModel;

%initialises a thread with equally spaced, locally controlled electrodes
thread = Thread.ConstructThreadWithSpacedElectrodes( ...
    preStretch, ...
    cellLengthAtPrestretch, ...
    nCells, ...
    spacingAtPrestretch, ...
    switchingModelLocal, ...
    switchingModelExternal, ...
    GentParams.Koh2012, ...
    @(x)FiberConstrainedElement(x, 1));

thread.SetAllElectrodeTypes(ElectrodeTypeEnum.ExternallyControlled);
thread.RCCircuit.Resistance = 1e7;

for i = length(thread.Electrodes) - nCellsActive: length(thread.Electrodes)
    thread.Electrodes(i).Type = ElectrodeTypeEnum.LocallyControlled;
end

name = strcat([mfilename, '_', int2str(nCellsActive), 'cells']);
sim = SimulateThread(name, thread);

end