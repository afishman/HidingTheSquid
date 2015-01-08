clear all
clc
close all

%Filenaame
filename = 'conwayXL';

%The number of cells
nCells=30;

%Pre stretch
lambdaPre=2.5;

%Cell spacing
d1 = 50e-3;%20e-3 * lambdaPre;
d2 = 100e-3;%40e-3 * lambdaPre;
res = 50e-3;

%The length
theLength = nCells*d1 + (nCells-1)*d2 + 0.3;

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
for i=1:nCells
    start=(i-1)*(d1+d2);
    
    %Paint and electrode
    obj = addElectrode(obj,start,50e-3);
end

%Set their Type
obj=setElecManual(obj, 1);
obj=setElecSelfSenser(obj, 2:nCells);

%Set the activation function
obj.actiFun = @(t)actiFunBin(t, 4000);

%Run the sim
runSim(obj,200);