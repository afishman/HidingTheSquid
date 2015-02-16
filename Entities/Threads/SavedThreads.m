classdef SavedThreads < handle
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function thread = TypeIBehaviour
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
            %switchingModelLocal = LocalAlwaysOffModel;
            
            timeOn = 0; timeOff = 6;
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
                @FiberConstrainedElement);
        end
    end
    
end

