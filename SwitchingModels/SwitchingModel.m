classdef SwitchingModel < handle
    %SWITCHINGMODEL models the control of electrodes. All switching models
    %should inherit from this class
    
    properties
    end
    
    methods (Abstract)
        %What the state of the switch should be. True for on, False for off
        %Params will be an electrode for self-sensers, or the time for
        %externally controlled switches
        State(this, params);
        
        %For the events function, this should approach 0 as the state
        %changes
        EventsFunValue(this, params);
        
        %params is 0 for all crossings, 1 for increasing, -1 for decreasing
        EventsFunDirection(this, params);
    end
    
    methods
        %For cleanliness let's always end exactly on a terminal state
        function isTerminal = EventsFunIsTerminal(this, params)
            isTerminal = true;
        end
    end
    
end
