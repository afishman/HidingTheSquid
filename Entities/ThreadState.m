classdef ThreadState < handle
%Stores the global, local and time of a thread

    properties
        Thread;
        LocalState;
        GlobalState;
        Time;
    end
    
    
    methods
        function this = ThreadState(thread, t, localState, globalState)
            this.Thread = thread;
            this.Time = t;
            
            %TODO: check the length of the states for consistency
            this.LocalState = localState;
            this.GlobalState = globalState;
        end
        
        function SetState(this)
            this.Thread.SetLocalState(this.LocalState);
            this.Thread.SetGlobalState(this.GlobalState);
        end
    end
end
