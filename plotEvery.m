function data = plotEvery(name, data)
close all
%Load the data
if nargin==1
    data = loadData(name);
end

figure
plotGlobal(name, data);

figure
plotMat(name, data);
% 
% figure
% plotDiscrete(name, data);

figure
plotSS(name, data);
% 
% figure
% plotLambda(name, data)