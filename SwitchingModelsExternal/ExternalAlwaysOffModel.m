classdef ExternalAlwaysOffModel < SwitchingModelExternal
    %This boring model is always off
    methods
        function this = ExternalAlwaysOffModel()
        end
        
        function state = State(this, t)
            state = false(1,length(t));
        end
        
        %linear crossing
        function value = EventsFunValue(this, t)
            value = ones(1,length(t));
        end
        
        %This is redundant for this model
        function direction=EventsFunDirection(this,t)
            direction = 0;
        end
        
    end
    
    methods (Static)
        function Demo()
            model = ExternalAlwaysOffModel();
            t = linspace(-1,3,100);
            
            states = model.State(t);
            crossings = model.Crossing(t);
            
            figure
            plot(t, states);
            grid on
            xlabel('t'); ylabel('state'); title('state');
            
            figure
            plot(t, crossings);
            grid on
            xlabel('t'); ylabel('Crossings'); title('Crossings');
        end
    end
end
