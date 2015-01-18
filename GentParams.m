classdef GentParams
   
    properties
    
        MuA=25000;
        MuB=70000;
        Ja=90;
        Jb=30;
        Tau=0.01;
    
    end
    
    methods 
    
        function this = GentParams(muA, muB, ja, jb, tau)
            this.MuA = muA;
            this.MuB = muB;
            this.Ja = ja;
            this.Jb = jb;
            this.Tau = tau;
        end
    
    end
    
end