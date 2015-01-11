classdef StepModel < SwitchingModelExternal
    %This model is turns on 
    
    properties
        TimeOn;
        TimeOff;
    end
    
    properties (SetAccess = 'private')
        %for the crossings function: f(x)=(x-a)^2 + b
        a;
        b;
    end
    
    methods
        function this = StepModel(timeOn, timeOff)
            this.TimeOn = timeOn;
            this.TimeOff = timeOff;
            
            this.a = (this.TimeOn^2 - this.TimeOff^2)/(2*(this.TimeOn - this.TimeOff));
            this.b = -(this.TimeOff-this.a)^2;
            
        end
        
        %For a change at a terminal state, we should change state at the
        %exact time of TimeOn/TimeOff
        function state = State(this, t)
            state = false(1,length(t));
            state(this.TimeOn <= t & t < this.TimeOff) = true;
        end
        
        %quadratic crossing
        function value = EventsFunValue(this, t)
            value = (t - this.a).^2 + this.b;
        end
        
        function direction = EventsFunDirection(this, t)
            if(t <= this.TimeOn)
                direction = -1;
            else
                direction = 1;
            end
        end
        
    end
    
    methods (Static)
        function Demo()
            stepModel = StepModel(1,2);
            t = linspace(-1,3,100);
            
            states = stepModel.State(t);
            values = stepModel.EventsFunValue(t);
            
            figure
            plot(t, states);
            grid on
            xlabel('t'); ylabel('state'); title('state');
            
            figure
            plot(t, values);
            grid on
            xlabel('t'); ylabel('Crossings'); title('Crossings');
        end
    end
end

% %Binary: on before tSwitch, off otherwise
% function [state, crossings]=actiFunBin(t, tSwitch)
% 
% crossings = tSwitch-t;
% 
% if crossings>0
%     state = 1;
% else
%     state = 0;
% end
