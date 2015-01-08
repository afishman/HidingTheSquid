function oneNeighLong_str3(filename, v)


%The filename
filename = 'oneNeighLong_R_';

%Prestretch
lambdaPre = 2.5;

%The number of cells
nCells = 30;

%Cell spacing
d1 = 20e-3 * lambdaPre;
d2 = 30e-3 * lambdaPre;
res = d1/2;
Vs = 3459.5;
rOn = 3.7;
rOff = 2.6;

%The length
theLength = nCells*d1 + (nCells-1)*d2;
obj = simV101(theLength, res, lambdaPre);


obj.R = 100000;
filename = [filename, sprintf('%.0f', obj.R)];


obj.ppS = 100;




%Make the object

obj.Vs = Vs;

%Set the name
obj.name=filename;
obj=changeTau(obj,3);

%Set the strain source and threshold
obj.ss = @ss1Neighbour;
obj.thresh = [rOn,rOff];

%Add the electrodes
for i=1:nCells
    start=(i-1)*(d1+d2);
    
    %Paint and electrode
    obj = addElectrode(obj,start,d1);
end

%Set their Type
obj=setElecManual(obj, 1:nCells);
obj=setElecSelfSenser(obj, 2:nCells);

%Set the activation function
% obj.actiFun = @(t)actiFunCyclic(t, 8, 300);
obj.actiFun = @(t)actiFunBin(t, 1);

runSim(obj,500);
