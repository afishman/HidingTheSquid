classdef Gent_ModelFiberConstrained < Gent_Model
    %Gent_Model defines the internal stress response of
    %DE.
    
    properties
        %Material Model (Gent) Parameters
%         MuA=25000;
%         MuB=70000;
%         Ja=90;
%         Jb=30;
%         Tau=0.01;
        
        Lambda1Pre;
    end
    
    methods
        
        %TODO: A default / parameterised constructor
        function this = Gent_ModelFiberConstrained(lambda1Pre)
            if lambda1Pre <0
                error('lmabda1Pre must be bigger than 0');
            end
            
            this.Lambda1Pre = lambda1Pre;
        end
        
        function eta = Eta(this)
            eta = 6 * this.Tau * this.MuB;
        end
        
        function stress = Stress(this, lambda, xi)
            lambda1Pre = this.Lambda1Pre;
            prodm2 = (lambda*lambda1Pre).^-2; %This comes up alot
            
            netA = this.MuA*(lambda.^2 - prodm2) ./ ...
                (1 - (lambda.^2 + lambda1Pre.^2 + prodm2)./this.Ja);
            
            
            netB = this.MuB.*(lambda^2*xi^-2 - lambda^-2*xi^2) ./ ...
                (1 - (lambda^2*xi^-2 + lambda^-2*xi*2 - 2)/this.Jb);
            
            
            %The total stress
            stress = netA + netB;
        end
        
        function dXi = DXi(this, lambda, xi)
            product = (lambda/xi).^2; %this comes up alot
            
            dXi = this.MuB * (product + 0.5/product + 0.5) ./ ...
                (1 - (product + 1/product - 2)./this.Jb);
            
            dXi = dXi / (3*this.Eta);
        end
    end
    
end

