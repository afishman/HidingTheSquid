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
        

    end
    
end

