%The filename
filename = 'oneNeighLong';
tau=3;

%Prestretch
lambdaPre = 2.5;

%The number of cells
nCells = 30;

%Cell spacing
d1 = 20e-3 * lambdaPre;
d2 = 40e-3 * lambdaPre;
res = d1;

%The length
theLength = nCells*d1 + (nCells-1)*d2;

%Make the object
obj = simV101(theLength, res, lambdaPre);

%Set the name
obj.name=filename;
obj=changeTau(obj,tau);

%Set the strain source and threshold
obj.ss = @ss1Neighbour;
obj.thresh = [3.7, 2.6];

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
obj.actiFun = @(t)actiFunCyclic(t, 40, 700);
% 
runSim(obj,700)
