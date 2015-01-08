names{1} = '2ss_mat_both.pdf';
names{2} = '2ss_global_both.pdf';









%%%%%%%%%%%%%%%%%%%%%%Full Conway
%The name of the Figure
name = 'conwayXL_20sBin';
t = [600,2000];


%Load the Data
dataAll = loadData(name,1);

dataZoom = loadData(name,1,t);



% 

% %The Material
% close all
% plotMat(name, data);
% savePlotPdf(names{5});
% 



%% Plot Global
close all; hold on
subplot(2,1,1)
plotGlobal(name, dataAll);

linewidth=3;color='r';

h=findobj(gcf,'Type','axes','Tag','legend');
set(h, 'Location','NorthWest')


%Save
% savePlotPdf(names{6});

%%%%%ZOOOM
subplot(2,1,2)
nCells = 14;
t = [600,2000];
yLimits=[0, 2.25];

%Save
plotGlobal(name, dataZoom)
h= findobj(gcf,'Type','axes','Tag','legend');
set(h, 'Location','NorthWest')
ylim([1, nCells+1]-0.5)

% Create textarrow
% annotation('textarrow',[0.386904761904762 0.30297619047619],...
%     [0.874679062521168 0.794726681568787],'TextEdgeColor','none',...
%     'TextLineWidth',3,...
%     'LineWidth',3,...
%     'Color',[1 0 0]);

% % Create ellipse
% annotation('ellipse',...
%     [0.153333333333333 0.692745376955903 0.156190476190476 0.145729187834459],...
%     'LineWidth',3,...
%     'Color',[1 0 0]);

% Create ellipse
% annotation('ellipse',...
%     [0.271428571428571 0.586059743954481 0.320952380952381 0.142247510668563],...
%     'LineWidth',3,...
%     'Color',[1 0 0]);

% Create textbox
annotation('textbox',...
    [0.391295407910563 0.857989031985907 0.224761904761905 0.0497866287339972],...
    'String',{'Patterned Configuration'},...
    'FontSize',15,...
    'FitBoxToText','off',...
    'BackgroundColor',[1 1 1],...
    'Color',[1 0 0],...
    'FitBoxToText','on'...
    );

% Create arrow
% annotation('arrow',[0.51673742305243 0.478523137338145],...
%     [0.842061159240924 0.731590885160453],'LineWidth',3,'Color',[1 0 0]);


annotation('textbox',...
    [0.294642857142857 0.587115666178624 0.272964869454469 0.150805270863836],...
    'FitBoxToText','off',...
    'EdgeColor',[1 0 0],...
    'LineWidth',3);



% Create line
annotation('line',[0.293333333333333 0.203566121842496],...
    [0.614509246088193 0.455445544554455],...
    'LineWidth',3,'Color',[1 0 0]);

% Create line
annotation('line',[0.56952380952381 0.784761904761905],...
    [0.614509246088193 0.455192034139403],...
    'LineWidth',3,'Color',[1 0 0]);




savePlotPdf(names{1});


%% Plot Material
close all; hold on
subplot(2,1,1)
plotMat(name, dataAll);

linewidth=3;color='r';

h=findobj(gcf,'Type','axes','Tag','legend');
set(h, 'Location','NorthWest')


%Save
% savePlotPdf(names{6});

%%%%%ZOOOM
subplot(2,1,2)
t = [600,2000];
yLimits=[0, 2.25];

%Save
plotMat(name, dataZoom)
h= findobj(gcf,'Type','axes','Tag','legend');
set(h, 'Location','NorthWest')
ylim(yLimits)


% Create line
annotation('line',[0.269642857142857 0.203566121842496],...
    [0.597619047619048 0.455445544554455],'LineWidth',3,'Color',[1 0 0]);

% Create line
annotation('line',[0.580357142857143 0.784761904761905],...
    [0.604761904761905 0.455192034139403],'LineWidth',3,'Color',[1 0 0]);

% % Create ellipse
% annotation('ellipse',...
%     [0.252840909090909 0.575643077287814 0.346642316017316 0.170450672712186],...
%     'LineWidth',3,...
%     'Color',[1 0 0]);
% 
% % Create ellipse
% annotation('ellipse',...
%     [0.180397727272727 0.703125 0.126420454545455 0.158854166666667],...
%     'LineWidth',3,...
%     'Color',[1 0 0]);

annotation('textbox',...
    [0.269642857142857 0.595238095238095 0.306818181818181 0.138169642857145],...
    'FitBoxToText','off',...
    'LineWidth',3,...
    'EdgeColor',[1 0 0]);


savePlotPdf(names{2});





% % Create ellipse
% annotation('ellipse',...
%     [0.271428571428571 0.586059743954481 0.320952380952381 0.142247510668563],...
%     'LineWidth',3,...
%     'Color',[1 0 0]);
% 
% % Create line
% annotation('line',[0.293333333333333 0.203566121842496],...
%     [0.614509246088193 0.455445544554455],...
%     'LineWidth',3,'Color',[1 0 0]);
% 
% % Create line
% annotation('line',[0.56952380952381 0.784761904761905],...
%     [0.614509246088193 0.455192034139403],...
%     'LineWidth',3,'Color',[1 0 0]);



