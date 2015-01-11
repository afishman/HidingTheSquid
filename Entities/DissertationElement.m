classdef DissertationElement < Element
    %Cunningly named after the one I did for my master's dissertatioan
    
    methods
        %Nothing special here
        function this = DissertationElement( ...
            startVertex, ...
            endVertex, ...
            preStretch, ...
            naturalLength, ...
            naturalWidth, ...
            internalStressModel, ...
            materialProperties)
        
            this@Element(startVertex, endVertex, preStretch, naturalLength, naturalWidth, internalStressModel, materialProperties);
        end
        
        function capacitance = Capacitance(this)
            capacitance = this.MaterialProperties.RelativeDielectricConstant ...
                .* this.NaturalLength.^2 .* this.NaturalThickness.^-1 .* this.StretchRatio.^4;
        end
        
        function capDot = CapacitanceDot(this)
            capDot = 4 * this.StretchRatio.^3 * this.StretchVelocity * this.NaturalLength.^2 * this.NaturalThickness.^-1 * this.MaterialProperties.RelativeDielectricConstant;
        end
        
        function width = Width(this)
            width = this.StretchRatio * this.NaturalWidth;
        end
        
    end
end