clear all;close all;clc

name = 'sawOsc2';
name='oneNeighLong_R_100000';
[data, obj] = loadData(name,10);

close all;clc

figure
plotMat(obj.name, data);

figure
plotGlobal(obj.name, data);

figure
plotVolt(obj.name, data)

figure
plotLambda(obj.name, data);

figure
plotXi(obj.name, data);

% 
% figure
% plotDiscrete(name, data);
% 
figure
plotSS(name, data);


figure
plotVolt(name, data)


figure
plotLambda(name, data)