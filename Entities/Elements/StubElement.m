classdef StubElement < Element
    %Just a stub to make sure any eleent works in the thread
    
    methods
        %Nothing special here
        function this = StubElement( ...
            startVertex, ...
            endVertex, ...
            preStretch, ...
            naturalLength, ...
            internalStressModel, ...
            materialProperties)
        
            this@Element(startVertex, endVertex, preStretch, naturalLength, naturalWidth, internalStressModel, materialProperties);
        end
        
        function capacitance = Capacitance(this)
            capacitance = 0;
        end
        
        function capDot = CapacitanceDot(this)
            capDot = 0;
        end
        
        function width = Width(this)
            width = 0;
        end
        
        function naturalWidth = NaturalWidth(this)
            naturalWidth = 0;
        end
        
        function stress = MaterialStress(this)
            stress = 0;
        end
        
        function dXi = DXi(this)
            dXi = 0;
        end
    end
end