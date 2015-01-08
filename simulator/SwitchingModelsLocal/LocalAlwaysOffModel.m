classdef LocalAlwaysOffModel < SwitchingModelLocal
    %LocalAlwaysOffModel This boring model is always off
    
    methods
        function this = LocalAlwaysOffModel()
        end
        
        function state = ActivationRule(this, electrode)
            state = false;
        end
        
        function state = DeactivationRule(this, electrode)
            state = false;
        end
        
        function value = EventsFunValue(this, electrode)
            value = 1;
        end
        
        function dir = EventsFunDirection(this, electrode)
            dir = 1;
        end
        
        function source = Source(this, electrode)
            source = 0;
        end
    end
    
end

