classdef TypeIIModel < SwitchingModelLocal
    %The source of the typeII model is the mean strain across the previous
    %electrode's elements
    properties
        ROn
        ROff;
    end
    
    methods
        function this = TypeIIModel(rOn, rOff)
            if(rOn <= 0)
                error('TypeIIModel rOn should be > 0!')
            end
            
            if(rOff <= 0)
                error('TypeIIModel rOff should be > 0!')
            end
            
            this.ROn = rOn;
            this.ROff = rOff;
        end
        
        function source = Source(this, electrode)
            if(~isempty(electrode.PreviousElectrode))
                source = electrode.PreviousElectrode.StretchRatio;
            else
                source = 0;
            end
        end
        
        function state = ActivationRule(this, electrode)
            state = this.Source(electrode) >= this.ROn;
        end
        
        function state = DeactivationRule(this, electrode)
            state = this.Source(electrode) <= this.ROff;
        end
        
        %Linear crossings used here
        function value = EventsFunValue(this, electrode)
            if(electrode.GlobalState)
                value = this.Source(electrode) - this.ROff;
            else
                value = this.Source(electrode) - this.ROn;
            end
        end
        
        function direction = EventsFunDirection(this, electrode)
            if(electrode.GlobalState)
                direction = -1;
            else
                direction = 1;
            end
        end
    end
    
    methods (Static)
        %TODO:
        function Demo
        end
    end
end