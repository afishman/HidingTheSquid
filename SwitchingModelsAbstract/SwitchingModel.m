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
        
        %This is 0 for all, 1 for increasing, -1 for decreasing
        %TODO: Use enums instead, that's really what it should be using, if
        %they'd put more effort into it
        EventsFunDirection(this, params);
    end
    
    methods
        %As a clean design pattern let's always end exactly on a terminal state
        function isTerminal = EventsFunIsTerminal(this, params)
            isTerminal = true;
        end
    end
    
end
