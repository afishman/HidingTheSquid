classdef Gent_Model < handle
    %Gent_Model defines the internal stress response of
    %DE.
    
    properties
        %Material Model (Gent) Parameters
        MuA=25000;
        MuB=70000;
        Ja=90;
        Jb=30;
        Tau=0.01;
    end
    
    methods
        %TODO: A default / parameterised constructor
        function this = Gent_Model()
            %TODO checks for non-zero and such
        end
        
        function eta = Eta(this)
            eta = 6 * this.Tau * this.MuB;
        end
        
        function stress = Stress(this, lambda, xi)
            %Network A
            netA = (this.MuA * (lambda.^2 - lambda.^-4)) / ...
                   (1 - (2*lambda.^2 + lambda.^-4 - 3)./ this.Ja);

            %Network B
            netB = (this.MuB * (lambda.^2 .* xi.^-2 - lambda.^-4 .* xi.^4)) / ...
                   (1 - (2*lambda.^2 .* xi.^-2 + lambda.^-4 .* xi.^4 - 3) ./ this.Jb);
            
            %The total stress
            stress = netA + netB;
        end
        
        function dXi = DXi(this, lambda, xi)
            dXi = (this.MuB * this.Jb * xi .* (lambda.^-4 .* xi.^4 - lambda.^2 .* xi.^-2)) ...
                / (this.Eta * (2*lambda.^2 .* xi.^-2 + lambda.^-4 .* xi.^4 - 3 - this.Jb));
        end
    end
    
end

