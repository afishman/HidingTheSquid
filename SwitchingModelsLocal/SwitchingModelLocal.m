classdef SwitchingModelLocal < SwitchingModel
    %SWITCHINGMODELLOCAL models the control of locally controlled
    %electrodes.
    
    methods (Abstract)
        %As on the paper
        Source(this, electrode);
        
        %If the rule returns true, the electrode should toggle its state
        ActivationRule(this, electrode);
        DeactivationRule(this, electrode);
        
        %Fun Fun!
        EventsFunValue(this, electrode);
        EventsFunDirection(this, electrode);
    end
    
    methods
        function state = State(this, electrode)
            if(electrode.GlobalState)
                state = ~DeactivationRule(this, electrode);
            else
                state = ActivationRule(this, electrode);
            end
        end
    end
    
end

