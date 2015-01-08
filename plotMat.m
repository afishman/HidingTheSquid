function data=plotMat(name,data,tLines)
% close all
% clear all;clc
% name ='fig27_ext';

if nargin==0
    %Load the data
    name = 'demo';
end

load([name,'.mat'])

if nargin==1
    data =loadData(name);
end

% data.t = adjustToTC(obj, data.t);
xlabelStr = 'Time Constants';

%The line width
linewidth=2;

%Make a figure
hold on

%Find all the electroded elements
allElecElem = zeros(obj.nElem,1);
for i=1:length(obj.electrodes)
    allElecElem(obj.electrodes{i})=1;
end

%Work out the node positions
theOnes = ones(length(data.t), 1);
zeroDisp = linspace(0, obj.theLength, obj.nNodes);
nodePos = data.disp + theOnes*zeroDisp;

%Cycle through the each element and plot
for i=1:obj.nElem
    currElem = obj.nElem+1-i;
    currNode = currElem+1;
    
    %Cycle through each one and plot an area
    h=area(data.t, nodePos(:,currNode));
    
    %If it is electroded paint it black
    if allElecElem(currElem)
        areaColor = [0,0,0];
        lineColor = 'k--';
        
        %Otherwise white
    else
        areaColor = [1,1,1];
        lineColor = 'w--';
    end
    
    %Set the color of the faces
    set(h,'FaceColor',areaColor)
    set(h,'EdgeColor',areaColor)
    
    %Loop over each line
    if nargin==3
        for j=1:length(tLines)
            %Find the time of the current line
            tLine = tLines(j);
            
            %Find the start and end point of the line
            lineSpan(1) = interp1(data.t, nodePos(:,currNode),tLine);
            lineSpan(2) = interp1(data.t, nodePos(:,currNode-1),tLine);
            
            %Get it is electroded do a white line
            if allElecElem(currElem)
                lineColor = 'w--';
            else
                lineColor = 'k--';
            end
            
            %lot it
            plot([tLine, tLine], lineSpan, lineColor,'linewidth',linewidth)
        end
    end
end

%Set the y-limits
ylim([0 obj.theLength])
xlim([data.t(1) data.t(end)])

% %Get the limits
% labels = get(gca, 'XTick');
% newLabelsDouble = adjustToTC(obj, labels);
% for i=1:length(labels)
%     newLabels{i} = sprintf('%.0f',newLabelsDouble(i));
% end
% set(gca, 'XTickLabel', newLabels);

%And the labels
xlabel(xlabelStr)
ylabel('Length Along Thread (m)')

% title('Material View')
