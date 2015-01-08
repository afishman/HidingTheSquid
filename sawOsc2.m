clearvars
clc

%The filename
filename = 'sawOsc2';

%Prestretch
lambdaPre = 2.5;

%The number of cells
nCells = 2;

%Cell spacing
d1 = 20e-3 * lambdaPre;
d2 = 80e-3 * lambdaPre;
R = 500;
res = d1;

%The length
theLength = nCells*d1 + (nCells-1)*d2;

%Make the object
obj = SimV101(theLength, res, lambdaPre);
obj.R = R;
%Set the name
obj.name=filename;

%Set the strain source and threshold
obj.ss = @ssPersonal;
obj.thresh =  [2, 4.8];

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
obj.actiFun = @(t)actiFunBin(t, 1000);

runSim(obj,1700);
