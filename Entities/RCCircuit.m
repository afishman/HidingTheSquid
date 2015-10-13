classdef RCCircuit < handle
    %RCCIRCUIT holds the parameters of a serial RC Circuit
    
    properties
        Resistance; %Ohms
        SourceVoltage;    %Volts
    end
    
    methods
        function this = RCCircuit(resistance, sourceVoltage)
            this.Resistance = resistance;
            this.SourceVoltage = sourceVoltage;
        end
    end
    
    methods (Static)
        function this = Default
            R = 5.14e7;
            V = 3459.5;
            
            this = RCCircuit(R, V);
        end
    end
end

