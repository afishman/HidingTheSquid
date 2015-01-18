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
                materialProperties, ...
                lambda2Pre)
            
            if(lambda2Pre < 0 )
                error('lambda 2 pre must be > 0 !')
            end
            
            this@Element(startVertex, endVertex, preStretch, naturalLength, materialProperties);
            
            this.Lambda2Pre = lambda2Pre;
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
            
            lambda2Pre = this.Lambda2Pre;
            prodm2 = (lambda*lambda2Pre).^-2; %This comes up alot
            
            
            netA = this.MuA*(lambda.^2 - prodm2) ./ ...
                (1 - (lambda.^2 + lambda2Pre.^2 + prodm2)./this.Ja);
            
            
            netB = this.MuB.*(lambda^2*xi^-2 - lambda^-2*xi^2) ./ ...
                (1 - (lambda^2*xi^-2 + lambda^-2*xi^2 - 2)/this.Jb);
            
            
            %The total stress
            stress = (netA + netB);
        end
        
        function dXi = DXi(this)
            lambda = this.StretchRatio;
            xi = this.Xi;
            
            product = (lambda/xi).^2; %this comes up alot
            
            dXi = this.MuB * (product - 0.5/product - 0.5) ./ ...
                (1 - (product + 1/product - 2)./this.Jb);
            
            dXi = dXi / (3*this.Eta);
        end
        
        
    end
    
    methods (Static)
        
        function Demo(varargin)
            if(nargin==1)
                prestretch = varargin{1};
            else
                prestretch = 1;
            end
            
            element = FiberConstrainedElement(0, 0, prestretch, 1, Material_Properties.Default, prestretch);

            Element.Demo(element);
        end
        
    end
end
