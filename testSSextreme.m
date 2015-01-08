clear all
clc
close all

%Filenaame
filename = 'testSS';

%The number of cells
nCells=30;


%%%The test list
testList = zeros(1,nCells);
testList(1, 1:29) = 1;
testList(end+1, 1) = 1;





%%%Make base object
%Pre stretch
lambdaPre=2.5;

%Cell spacing
d1 = 50e-3;%20e-3 * lambdaPre;
d2 = 100e-3;%40e-3 * lambdaPre;
res = 50e-3;

%The length
theLength = nCells*d1 + (nCells-1)*d2;

%Make the object
mainObj = simV101(theLength, res, lambdaPre);

%Set the name
mainObj.name=filename;

%Set the strain source and threshold
mainObj.ss = @ss2NeighbourV3;
mainObj.thresh =  [3.4,4.0, 2.6,4.6];

%Set the voltage
mainObj.Vs=3459.5;

%Add the electrodes
for i=1:nCells
    start=(i-1)*(d1+d2);
    
    %Paint and electrode
    mainObj = addElectrode(mainObj,start,50e-3);
end

%Set the activation function
mainObj.actiFun = @(t)actiFunBin(t, 4000);





%%%%Loop round and sim
for i=1:size(testList,1)
    %Refresh object
    currObj  = mainObj;
    
    %Set the name
    currObj.name = [filename, '_', num2str(i)];
    
    %Which cells to turn on
    cells = find( testList(i,:) == 1);
    
    %Turn them on
    currObj= setElecManual(currObj, cells);
   
    runSim(currObj,200);
end
