%% 

clear all
clc
close all

names={
    'pss_osc_mat';
    'pss_osc_global';
    '1ss_30_mat';
    '1ss_30_net';
    '2ss_mat';
    '2ss_global';
    '2ss_mat_zoom';
    '2ss_global_zoom'
   };
    

%% %%%%%%%%%%%%%%%%%%%%%%Sawtooth
%The name of the Figure
name = 'sawOsc/sawOsc2_paper';

%Load the Data
data=loadData(name,1);

%The Material
plotMat(name, data);
savePlotPdf(names{1});

close all
%Plot it
plotGlobal(name, data);

%Legend Locatioan
h= findobj(gcf,'Type','axes','Tag','legend');
set(h, 'Location','NorthWest')

%Save
savePlotPdf(names{2});




%%  %%%Unidirectional
close all
%The name of the Figure
name = 'one neighbour/oneNeighLong_30_ext';

%Load the Data
data=loadData(name,1);

%The Material
plotMat(name, data);
savePlotPdf(names{3});


%Plot it
close all
plotGlobal(name, data);

%Legend Locatioan
h= findobj(gcf,'Type','axes','Tag','legend');
set(h, 'Location','SouthEast')

%Save
savePlotPdf(names{4});



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Full Conway






% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Full Conway
% %The name of the Figure
% name = 'conwayXL_20sBin';
% 
% %Load the Data
% data=loadData(name,1);
% 
% %The Material
% close all
% plotMat(name, data);
% savePlotPdf(names{5});
% 
% 
% 
% %%Plot it
% close all
% plotGlobal(name, data);
% 
% h=findobj(gcf,'Type','axes','Tag','legend');
% set(h, 'Location','NorthWest')
% 
% %Save
% savePlotPdf(names{6});
% 
% 
% 
% 
% %%%%%%%%%ZOOOM
% nCells = 14;
% t = [600,2000];
% yLimits=[0, 2.25];
% 
% close all
% %The name of the Figure
% name = 'conwayXL_20sBin';
% 
% %Load the Data
% data=loadData(name,1,t);
% 
% %The Material
% plotMat(name, data);
% ylim(yLimits)
% savePlotPdf(names{7});
% 
% %Plot it
% close all
% plotGlobal(name, data);
% 
% %Save
% h= findobj(gcf,'Type','axes','Tag','legend');
% set(h, 'Location','NorthWest')
% ylim([1, nCells+1]-0.5)
% savePlotPdf(names{8});
