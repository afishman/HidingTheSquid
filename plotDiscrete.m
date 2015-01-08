% function data=plotDiscrete(name, data)
% %Load data
% if nargin==2
%     load(name)
% else
%     [data, obj] = loadData(name,1);
% end

hold on

%For the legend
x=0;y=0; lw=5;
plot(x,y,'b','linewidth',lw)
plot(x,y,'r','linewidth',lw)
legend('G(i) = 0', 'G(i) = 1')

%plot the image
imagesc(1:length(data.discrete.t),1:obj.nElec, data.discrete.global');

%The limits
xlim([1, max([1.01,length(data.discrete.t)])])
yLimits = [0.5,obj.nElec+0.5];
ylim(yLimits);

%yaxis ticks
set(gca, 'YTick', 1:obj.nElec)

%xaxis tick
xTick = get(gca, 'XTick');
for i=1:length(xTick)
    xTickLabel{i} = sprintf('%.0f',data.discrete.t(xTick(i)));
%     line([xTick(i),xTick(i)], yLimits)
end


set(gca, 'XTick', xTick)
set(gca, 'XTickLabel', xTickLabel)

%And the gridlines
theList = 0.5:1:obj.nElec+0.5;
for i=1:obj.nElec
    x=[data.t(1), data.t(end)];
    y=[theList(i), theList(i)];
    plot(x,y,'k')
end

%THe labels
xlabel('Time (s)')
ylabel('Cell')

title('Global Transition: DISCRETE')
