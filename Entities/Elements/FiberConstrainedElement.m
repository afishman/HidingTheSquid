classdef FiberConstrainedElement < Element
    %FIBERCONSTRAINEDELEMENT, derivation of equations in the paper
    
    properties
        Lambda2Pre;
    end
    
    methods
        %Assumes a width prestretch equal to length prestretch if not
        %defined
        function this = FiberConstrainedElement(elementParams, preStretch2)
            
            this@Element(elementParams);
            
            if nargin > 7
                this.Lambda2Pre = preStretch2;
            else
                this.Lambda2Pre = this.PreStretch;
            end
            
        end
        
        function capacitance = Capacitance(this)
            capacitance = this.MaterialProperties.RelativeDielectricConstant ...
                .* this.NaturalLength.^2 .* this.NaturalThickness.^-1 .* this.StretchRatio.^4;
        end
        
        %Rate of change of Capacitance
        function capDot = CapacitanceDot(this)
            capDot = 4 * this.StretchRatio.^3 * this.StretchVelocity * this.NaturalLength.^2 * this.NaturalThickness.^-1 * this.MaterialProperties.RelativeDielectricConstant;
        end
        
        function width = Width(this)
            width = this.Lambda2Pre * this.NaturalWidth;
        end
        
        %For simplicity
        function naturalWidth = NaturalWidth(this)
            naturalWidth = this.NaturalLength;
        end
        
        function stress = MaterialStress(this)
            lambda = this.StretchRatio;
            xi = this.Xi;
            
            muA = this.GentParams.MuA;
            muB = this.GentParams.MuB;
            ja = this.GentParams.Ja;
            jb = this.GentParams.Jb;
            
            lambda2Pre = this.Lambda2Pre;
            
            %For clarity, this comes up alot...
            prodm2 = (lambda*lambda2Pre).^-2;
            
            
            netA = muA*(lambda.^2 - prodm2) ./ ...
                (1 - (lambda.^2 + lambda2Pre.^2 + prodm2)./ja);
            
            
            netB = muB.*(lambda^2*xi^-2 - lambda^-2*xi^2) ./ ...
                (1 - (lambda^2*xi^-2 + lambda^-2*xi^2 - 2)/jb);

            %The total stress
            stress = (netA + netB);
        end
        
        %Rate of chage of xi
        function dXi = DXi(this)
            lambda = this.StretchRatio;
            xi = this.Xi;
            
            product = (lambda/xi).^2; %this comes up alot
            
            muB = this.GentParams.MuB;
            jb = this.GentParams.Jb;
            
            dXi = muB * (product - 0.5/product - 0.5) ./ ...
                (1 - (product + 1/product - 2)./jb);
            
            dXi = dXi / (3*this.Eta);
        end
       
        
        function rcCircuit = DefaultRCCircuit(this)
            resistance = 2000000;
            voltage = 5600;
            rcCircuit = RCCircuit(resistance, voltage);
        end
        
    end
end
