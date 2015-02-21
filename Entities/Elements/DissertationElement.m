classdef DissertationElement < Element
    %Cunningly named after the one I did for my master's dissertatioan
    %Assumes the width and length are always the same
    
    methods
        %Nothing special here
        function this = DissertationElement(elementParams)
        
            this@Element(elementParams);
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
            
            muA = this.GentParams.MuA;
            muB = this.GentParams.MuB;
            ja = this.GentParams.Ja;
            jb = this.GentParams.Jb;
            
            %Network A
            netA = (muA * (lambda.^2 - lambda.^-4)) / ...
                   (1 - (2*lambda.^2 + lambda.^-4 - 3)./ ja);

            %Network B
            netB = (muB * (lambda.^2 .* xi.^-2 - lambda.^-4 .* xi.^4)) / ...
                   (1 - (2*lambda.^2 .* xi.^-2 + lambda.^-4 .* xi.^4 - 3) ./ jb);
            
            %The total stress
            stress = netA + netB;
        end
        
        function dXi = DXi(this)
                        %TODO: Neaten this
            lambda = this.StretchRatio;
            xi = this.Xi;
            
            muB = this.GentParams.MuA;
            jB = this.GentParams.MuB;
            
            dXi = (muB * jB* xi .* (lambda.^-4 .* xi.^4 - lambda.^2 .* xi.^-2)) ...
                / (6 * this.Eta * (2*lambda.^2 .* xi.^-2 + lambda.^-4 .* xi.^4 - 3 - jB));
        end
        
        function rcCircuit = DefaultRCCircuit(this)
            resistance = 500;
            voltage = 3459.5;
            rcCircuit = RCCircuit(resistance, voltage);
        end
    end
    
    methods (Static)

        
        
        function Demo(varargin)
            element = DissertationElement(0, 0, 1, 1, Material_Properties.Default);
            Element.Demo(element);
        end
        
        
    end
end