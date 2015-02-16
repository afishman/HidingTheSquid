classdef SavedEnumerations
    %SAVEDENUMERATIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function TypeIChangeTau
            sim = SavedSims.TypeIBehaviour;
            
            key = @(tau, sim) SavedEnumerations.SetTau(tau, sim); 
            list = linspace(0.003, 3, 20);
            
            enumeration = SimEnumeration(sim, key, list, 7);
        end
        
        function SetTau(tau, sim)
            sim.Thread.StartElement.GentParams.Tau = tau;
        end
    end
    
end

