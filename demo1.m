clear all; clc; close all
%%% Demo Code for the 'hiding the squid' simulations
%%% Simulates a smaller version of: http://seis.bris.ac.uk/~af8291/expert.html
%%% The code plots the initial conditions, to simulate uncomment the last
%%% lines (takes a little while!)


%%%%%Demo parameters


%The number of cells
nCells=4;




%%%%%Main Routine

%Filenaame
filename = 'demo1';

%Pre stretch
lambdaPre=2.5;

%Cell spacing
d1 = 50e-3; %Cell Width (mm)
d2 = 100e-3; % Cell spacing (mm)
res = 50e-3; % Discretisation resolution (mm)

%The length of the thread
theLength = nCells*d1 + (nCells-1)*d2;

%Make the simulation object
obj = simV101(theLength, res, lambdaPre);

%Set the name
obj.name=filename;

%Set the strain source and threshold
obj.ss = @ss2NeighbourV3;
obj.thresh =  [3.1,4.1, 2.7,4.9];

%Set the source voltage
obj.Vs=3459.5;

%Paint each electrodes
for i=1:nCells
    start=(i-1)*(d1+d2);
    
    %Paint and electrode
    obj = addElectrode(obj, start, d1);
end



%Set their Type
obj=setElecManual(obj, 1);
obj=setElecSelfSenser(obj, 2:nCells);



%Show the setup
plotSetup(obj)



%%%%%% If you have the spare time :)
% %Set the activation function
% obj.actiFun = @(t)actiFunBin(t, 4000);
% 
% %Run the sim
% %Set the strain source and threshold
% obj.ss = @ss1Neighbour;
% obj.thresh = [3.7, 2.6];
% 
% %Set the activation function
% obj.actiFun = @(t)actiFunCyclic(t, 40,800);
% 
% %Rune the simulation
% runSim(obj,1000);
% 
% %Plot the Result
% close all;
% plotMat(filename)

