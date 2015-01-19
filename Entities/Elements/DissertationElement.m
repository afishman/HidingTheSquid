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
        
        function gentParams = DefaultGentParams(this)
           muA=25000;
           muB=70000;
           ja=90;
           jb=30;
           tau=0.01;
            
           gentParams = GentParams(muA, muB, ja, jb, tau);
        end
        
        function rcCircuit = DefaultRCCircuit(this)
            rcCircuit = RCCircuit(3459.5, 500);
        end
    end
    
    methods (Static)

        
        
        function Demo(varargin)
            element = DissertationElement(0, 0, 1, 1, Material_Properties.Default);
            Element.Demo(element);
        end
        
        
    end
end