function savePlotPdf(filename)

% clear all
filepath = 'D:\Work\school work\Project\Journal\images\graphs\';
% filename = 'cuttleDemo';
% 
% filepath='';
% filename='temp.pdf';

%Output files name
outfilename = [filepath, filename];

%The figure
h=gcf;


%Print etc.
input(',,,');
set(h,'Color','w')
set(h,'Units','Inches');
pos = get(h,'Position');
% set(h,'PaperPositionMode','Auto','PaperUnits','points','PaperSize',[633,402])
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
clc
disp(outfilename);
input(',,,');
% print(h,outfilename,'-dpng,'-r0')
