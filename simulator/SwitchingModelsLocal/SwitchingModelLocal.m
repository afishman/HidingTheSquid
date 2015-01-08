classdef SwitchingModelLocal < SwitchingModel
    %SWITCHINGMODELLOCAL Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Abstract)
        Source(this, electrode);
        ActivationRule(this, electrode);
        DeactivationRule(this, electrode);
        EventsFunValue(this, electrode);
        EventsFunDirection(this, electrode);
    end
    
    methods
        function state = State(this, electrode)
            if(electrode.GlobalState)
                state = DeactivationRule(this, electrode);
            else
                state = ActivationRule(this, electrode);
            end
        end
    end
    
end

