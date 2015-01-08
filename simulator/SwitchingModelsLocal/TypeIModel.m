classdef TypeIModel < SwitchingModelLocal
    %The typeI model is the mean strain across the electrode's elements
    properties
        ROn
        ROff;
    end
    
    methods
        function this = TypeIModel(rOn, rOff)
            if(rOn <= 0)
                error('TypeIModel rOn should be > 0!')
            end
            
            if(rOff <= 0)
                error('TypeIModel rOff should be > 0!')
            end
            
            this.ROn = rOn;
            this.ROff = rOff;
        end
        
        function source = Source(this, electrode)
            source = mean(arrayfun(@(x)x.StretchRatio,electrode.Elements));
        end
        
        function state = ActivationRule(this, electrode)
            state = this.Source(electrode) < this.ROn;
        end
        
        function state = DeactivationRule(this, electrode)
            state = this.Source(electrode) > this.ROff;
        end
        
        %Linear crossings used here
        function value = EventsFunValue(this, electrode)
            if(electrode.GlobalState)
                value = this.Source(electrode) - this.ROff;
            else
                value = this.Source(electrode) - this.ROn;
            end
        end
        
        %Since source increases value, the direction should be up
        function direction = EventsFunDirection(this, electrode)
            direction = 1;
        end
    end
    
    methods (Static)
        %TODO:
        function Demo
        end
    end
end

