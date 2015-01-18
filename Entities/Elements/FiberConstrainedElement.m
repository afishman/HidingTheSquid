classdef FiberConstrainedElement < Element
    %FIBERCONSTRAINEDELEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Lambda2Pre;
    end
    
    methods
        %Nothing special here
        function this = FiberConstrainedElement( ...
                startVertex, ...
                endVertex, ...
                preStretch, ...
                naturalLength, ...
                materialProperties)
            
            this@Element(startVertex, endVertex, preStretch, naturalLength, materialProperties);
            
            %TODO: adjust?
            this.Lambda2Pre = this.PreStretch;
        end
        
        
        function capacitance = Capacitance(this)
            capacitance = this.MaterialProperties.RelativeDielectricConstant ...
                .* this.NaturalLength.^2 .* this.NaturalThickness.^-1 .* this.StretchRatio.^4;
        end
        
        function capDot = CapacitanceDot(this)
            capDot = 4 * this.StretchRatio.^3 * this.StretchVelocity * this.NaturalLength.^2 * this.NaturalThickness.^-1 * this.MaterialProperties.RelativeDielectricConstant;
        end
        
        function width = Width(this)
            width = this.Lambda2Pre * this.NaturalWidth;
        end
        
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
            prodm2 = (lambda*lambda2Pre).^-2; %This comes up alot
            
            
            netA = muA*(lambda.^2 - prodm2) ./ ...
                (1 - (lambda.^2 + lambda2Pre.^2 + prodm2)./ja);
            
            
            netB = muB.*(lambda^2*xi^-2 - lambda^-2*xi^2) ./ ...
                (1 - (lambda^2*xi^-2 + lambda^-2*xi^2 - 2)/jb);

            %The total stress
            stress = (netA + netB);
        end
        
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
        
        function gentParams = DefaultGentParams(this)
            muA=18000;
            muB=42000;
            ja=110;
            jb=55;
            tau=0.003;
        
            gentParams = GentParams(muA, muB, ja, jb, tau);
        end
    end
    
    methods (Static)
        
        
        function Demo(varargin)
            if(nargin==1)
                prestretch = varargin{1};
            else
                prestretch = 1;
            end
            
            element = FiberConstrainedElement(0, 0, prestretch, 1, Material_Properties.Default);

            Element.Demo(element);
        end
       
        
    end
end
