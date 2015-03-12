classdef TypeIIIModel < SwitchingModelLocal
    %The intention behaviour for this type:
    % 2 neighbours activated -> off
    % 1 neighbour activated  -> on
    % 0 neighbours activated -> off
    %Just like in the paper :)
    
    properties (SetAccess = private)
        ROn1
        ROn2;
        
        ROff1;
        ROff2;
    
        %A pair of quadratics for the events function, of the form: (x-a)^2+b
        ROnA; ROnB
        ROffA; ROffB
    end
    
    methods
        function this = TypeIIIModel(rOn1, rOn2, rOff1, rOff2)
            if(rOn1 <= 0)
                error('TypeIIIModel rOn1 should be > 0!')
            end
            
            if(rOn2 <= 0)
                error('TypeIIIModel rOn2 should be > 0!')
            end
            
            if(rOff1 <= 0)
                error('TypeIIIModel rOff1 should be > 0!')
            end
            
            if(rOff2 <= 0)
                error('TypeIIIModel rOff2 should be > 0!')
            end
            
            this.ROn1 = rOn1;
            this.ROn2 = rOn2;
            
            this.ROff1 = rOff1;
            this.ROff2 = rOff2;
            
            %Quadratic coefficients for the events function
            [this.ROnA, this.ROnB] = Utils.QuadraticCoefficients(this.ROn1, this.ROn2);
            [this.ROffA, this.ROffB] = Utils.QuadraticCoefficients(this.ROff1, this.ROff2);
        end
        
        %This way the end electrode spends it time approaching the state of its only neighbour 
        function source = Source(this, electrode)
           source = sum(arrayfun(@(x) x.StretchRatio, electrode.Neighbours))/2;
        end
        
        function state = ActivationRule(this, electrode)
            source = this.Source(electrode);
            state = this.ROn1 <= source && source <= this.ROn2;
        end
        
        function state = DeactivationRule(this, electrode)
            source = this.Source(electrode);
            state = source <= this.ROff1 || this.ROff2 <= source;
        end
        
        %A pair of quadratics used here
        function value = EventsFunValue(this, electrode)
            source = this.Source(electrode);
            
            if(electrode.GlobalState)
                value = Utils.QuadraticFun(source, this.ROffA, this.ROffB);
            else
                value = Utils.QuadraticFun(source, this.ROnA, this.ROnB);
            end
        end
        
        %TODO: could maybe do direction based on the gradient, don't know
        %if the ode solver would enjoy a sudden change in direction though
        function direction = EventsFunDirection(this, electrode)
            direction = 0;
        end
    end
    
    methods (Static)
        %TODO:
        function Demo
        end
    end
end