classdef GentParams < handle
    
    properties
        
        MuA=25000;
        MuB=70000;
        Ja=90;
        Jb=30;
        Tau=0.3;
        
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
    
    methods(Static)
        
        %See: http://www.seas.harvard.edu/suo/papers/277.pdf
        function params = Koh2012
            muA=25000;
            muB=70000;
            ja=90;
            jb=30;
            tau=3;
            
            params = GentParams(muA, muB, ja, jb, tau);
        end
        
        %See http://www.seas.harvard.edu/suo/papers/265.pdf
        function params = Foo2012
            muA=18000;
            muB=42000;
            ja=110;
            jb=55;
            tau=400;
            
            params = GentParams(muA, muB, ja, jb, tau);
        end
        
        %https://www.ae.utexas.edu/~ruihuang/papers/SoftMat04.pdf
        function params = Lu2012
            muA=45000;
            muB=0;
            ja=120;
            jb=0;
            tau=400;
            
            params = GentParams(muA, muB, ja, jb, tau);
        end
        
        
    end
    
    
end