clear all
clc
close all

%Filenaame
filename = 'conwayLong';

%Pre stretch
lambdaPre=2.5;

%Cell spacing
d1 = 20e-3 * lambdaPre;
d2 = 50e-3 * lambdaPre;
res = 25e-3;

%The length
theLength = 5*d1 + 4*d2 + 0.5;

%Make the object
obj = simV101(theLength, res, lambdaPre);

%Set the name
obj.name=filename;

%Set the strain source and threshold
obj.ss = @ss2NeighbourV3;
obj.thresh =  [3.4,4.0, 2.6,4.6];

%Set the voltage
obj.Vs=3459.5;

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
obj.actiFun = @(t)actiFunBin(t, 4000);

%Run the sim
runSim(obj,200);
