classdef SavedSims
    %SAVEDSIMS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function sim=TypeIBehaviour
            
            thread = SavedThreads.TypeIBehaviour;
            simName = 'TypeIBehaviour';
            
%Make a simulator object and run for 7s
simName = mfilename;
sim = SimulateThread(simName, thread);
        end
    end
    
end

