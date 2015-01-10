classdef Gent_Model < handle
    %MATERIALPROPERTIES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %Material Model (Gent) Parameters
        MuA=25000;
        MuB=70000;
        Ja=90;
        Jb=30;
        Tau=3;
    end
    
    methods
        %TODO: A default / parameterised constructor
        function this = Gent_Model()
            %TODO checks for non-zero and such
        end
        
        function eta = Eta(this)
            eta = this.Tau * this.MuB;
        end
        
        function stress = Stress(this, lambda, xi)
            %Network A
            netA = (this.MuA * (lambda.^2 - lambda.^-4)) / ...
                   (1 - (2*lambda.^2 + lambda.^-4 - 3)./ this.Ja);

            %Network B
            netB = (this.MuB * (lambda.^2 .* xi.^-2 - lambda.^-4 .* xi.^4)) / ...
                   (1 - (2*lambda.^2 .* xi.^-2 + lambda.^-4 .* xi.^4) ./ this.Jb);
            
            %The total stress
            stress = netA + netB;
        end
        
        function dXi = DXi(this, lambda, xi)
            dXi = (this.MuB * this.Jb * xi .* (lambda.^-4 .* xi.^4 - lambda.^2 .* xi.^-2)) ...
                / (6 * this.Eta * (2*lambda.^2 .* xi.^-2 + lambda.^-4 .* xi.^4 - 3 - this.Jb));
        end
       
        
        function width = Width(this)
           width = this.NaturalWidth * this.StretchRatio;
        end
    end
    
end

