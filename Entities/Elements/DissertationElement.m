classdef DissertationElement < Element
    %Cunningly named after the one I did for my master's dissertatioan
    %Assumes the width and length are always the same
    
    methods
        %Nothing special here
        function this = DissertationElement( ...
            startVertex, ...
            endVertex, ...
            preStretch, ...
            naturalLength, ...
            materialProperties)
        
            this@Element(startVertex, endVertex, preStretch, naturalLength, materialProperties);
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
        
        function naturalWidth = NaturalWidth(this)
            naturalWidth = this.NaturalLength;
        end
                
        function stress = MaterialStress(this)
            %TODO: Neaten this
            lambda = this.StretchRatio;
            xi = this.Xi;
            
            %Network A
            netA = (this.MuA * (lambda.^2 - lambda.^-4)) / ...
                   (1 - (2*lambda.^2 + lambda.^-4 - 3)./ this.Ja);

            %Network B
            netB = (this.MuB * (lambda.^2 .* xi.^-2 - lambda.^-4 .* xi.^4)) / ...
                   (1 - (2*lambda.^2 .* xi.^-2 + lambda.^-4 .* xi.^4 - 3) ./ this.Jb);
            
            %The total stress
            stress = netA + netB;
        end
        
        function dXi = DXi(this)
                        %TODO: Neaten this
            lambda = this.StretchRatio;
            xi = this.Xi;
            
            dXi = (this.MuB * this.Jb * xi .* (lambda.^-4 .* xi.^4 - lambda.^2 .* xi.^-2)) ...
                / (this.Eta * (2*lambda.^2 .* xi.^-2 + lambda.^-4 .* xi.^4 - 3 - this.Jb));
        end
        
    end
    
    methods (Static)
       function Demo(varargin)
            element = DissertationElement(0, 0, 1, 1, Material_Properties.Default);
            Element.Demo(element);
        end
        
        
    end
end