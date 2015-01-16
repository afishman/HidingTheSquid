classdef CyclicSwitchModel < SwitchingModelExternal
    %This model turns on and off with the given period
    %TODO: A tStart
    
    properties (SetAccess = private)
        TStart;
        TEnd;
        Period;
    end
    
    
    methods
        function this = CyclicSwitchModel(tEnd, period)
            this.TEnd = tEnd;
            
            if(period <= 0)
                error('Period for cyclic switch model must be >0');
            end
            this.Period = period;
        end
        
        %For the equation: sin(c*t)
        function c = Coefficient(this)
            c = 2*pi/this.Period;
        end
        
        %The gradient check ensures a change of state always occurs when value=0
        function state = State(this,t)
            if t >= this.TEnd
                state = false;
                
            elseif Utils.WithinTolerance(this.EventsFunValue(t), 0)
                state = this.EventsFunValueGradient(t) > 0;
                
            else
                state = sin(this.Coefficient .* t) > 0;
            end
        end
        
        %Sinusoidal events function used here
        function value = EventsFunValue(this, t)
            if ~this.TEndBeforeNextCycle(t)
                value = sin(this.Coefficient .* t);
            else
                value = t - this.TEnd;
            end
        end
        
        %Note: Does not take into account TEnd!!!
        function gradient = EventsFunValueGradient(this, t)
            if ~this.TEndBeforeNextCycle(t)
                 gradient = this.Coefficient .* cos(this.Coefficient .* t);
            else
                gradient = 1;
            end
            
        end
        
        function bool = TEndBeforeNextCycle(this, t)
            bool = this.TEnd <= t + this.Period/2;
        end
        
        function direction = EventsFunDirection(this, t)
            direction = 0;
        end
        
    end
   
    methods (Static)
        function Demo()
            period = 0.3;
            tEnd = 2.9;
            t = 0 : 0.01 : 1.25 * tEnd;
            
            model = CyclicSwitchModel(tEnd, period);
            values = arrayfun(@(x) model.EventsFunValue(x), t);
            
            figure;
            plot(t, values);
            grid on
            xlabel('Time (s)');
            ylabel('Value');
            title('Events Function Value');
            
            figure;
            state = arrayfun(@(x) model.State(x), t);
            plot(t, state);
            grid on
            xlabel('Time (s)');
            ylabel('state');
            title('State');
            
            figure;
            grad = arrayfun(@(x) model.EventsFunValueGradient(x), t);
            plot(t, grad);
            grid on
            xlabel('Time (s)');
            ylabel('dValue / dt');
            title('Gradient of Events Fun Value');
        end
    end
    
end