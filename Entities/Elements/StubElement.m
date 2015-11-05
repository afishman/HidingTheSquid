classdef StubElement < Element
    %Just a stub. Pesky Matlab doesn't support empty arrays of abstract
    %elements
    
    methods
        function capacitance = Capacitance(this)
            capacitance = 0;
        end
        
        function width = Width(this)
            width = 0;
        end
        
        function naturalWidth = NaturalWidth(this)
            naturalWidth = 0;
        end
        
        function capDot = CapacitanceDot(this)
            capDot = 0;
        end
        
        function rcCircuit = DefaultRCCircuit(this)
            rcCircuit = 0;
        end
    end
    
    methods (Static)
        function stress = MaterialStress(this, gentParams)
            stress = 0;
        end
        
        
        function dXi = DXi(this, gentParams)
            dXi = 0;
        end
    end
    
end