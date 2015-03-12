classdef SimEnumeration < handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Sim;
        Key;
        List;
        Time = 10;
        
    end
    
    methods
        
        function this = SimEnumeration(sim, key, list, time)
            this.Sim=sim;
            this.Key = key;
            this.List = list;
            this.Enumerate;
            this.Time = time;
        end
        
        function Enumerate(this)
            originalName = this.Sim.Name;
            
            for item = this.List
                this.Sim.Name = sprintf('%s_%s', originalName, item);
                this.Key(item, this.Sim);
                this.Sim.RunSim(this.Time);
            end
        end
    end
    
end
