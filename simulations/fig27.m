clear all
clc
close all

filename = 'fig27';

%Pre stretch
lambdaPre=2.5;

%Cell spacing
d1 = 20e-3 * lambdaPre;
d2 = 50e-3 * lambdaPre;
res = 25e-3;

%The length
theLength = 5*d1 + 4*d2;

%Make the object
obj = simV101(theLength, res, lambdaPre);

%Set the name
obj.name=filename;

%Set the threshold
obj.thresh = [3.7, 2.6];

%Add the electrodes
start=0;
for i=1:5
    %Paint and electrode
    obj = addElectrode(obj,start,50e-3);
    
    %Move forward
    start = start + d1+d2;
end

%Set their Type
obj=setElecManual(obj, 1);
obj=setElecSelfSenser(obj, 2:5);

%Set the activation function
obj.actiFun = @(t)actiFunBin(t, 125);

%Run the sim
runSim(obj,300);
