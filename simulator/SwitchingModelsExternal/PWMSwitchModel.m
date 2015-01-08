%%TODO: make this a class that inherits from switchingmodel


%Cyclic: on before tSwitch, off otherwise
function [state, crossings]=PWMSwitchModel(t, period, dutyCycle, tEnd)

%For the events function
if t+period<tEnd
    crossings = sin(pi*t./period);
else
    crossings = t - tEnd;
end

%The state
if crossings>=0
    state=1;
else
    state=0;
end

%Ending
if t>=tEnd
    state=0;
end
