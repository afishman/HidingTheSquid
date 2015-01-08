classdef ThreadState < handle
    
    properties
        Thread;
        LocalState;
        GlobalState;
        Time;
    end
    
    
    methods
        %TODO: Apply state
        function this = ThreadState(thread, t, localState, globalState)
            this.Thread = thread;
            this.Time = t;
            
            %TODO: check the length
            this.LocalState = localState;
            this.GlobalState = globalState;
        end
        
        function SetState(this)
            this.Thread.SetLocalState(this.LocalState);
            this.Thread.SetGlobalState(this.GlobalState);
        end
    end
end