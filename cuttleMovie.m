clear all
clc
close all


%One neighbour Long
[data, obj]=loadData('oneNeighLong_paper', 1, [0, 1000]);
M=animateSim(obj, data);

%%
clear all; clc
%One neighbour Long
[data, obj]=loadData('conwayXL_20sBin', 1, [0, 1000]);
M=animateSim(obj, data);

% close all;movie(M,2,20)
