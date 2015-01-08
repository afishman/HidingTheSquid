function data=plotGlobal(name, data)
% close all

%%%%Plotting Colours
c1 = [1,1,1];
c2 = [0,0,0];
legColor = [0.8, 0.8,1];
gridColor = [0.3, 0.3, 0.3];


%%%%Main Routine
%Load data
if nargin==2
    load([name,'.mat'])
else
    [data, obj] = loadData(name);
end

hold on

% data.t = adjustToTC(obj, data.t);
xlabelStr = 'Time Constants';

%For the legend
x=0;y=0; ms=15;
plot(x,y,'marker','square','markersize',ms,...
       'markeredgecolor','k','markerfacecolor',c1,...
       'color','w');
plot(x,y,'marker','square','markersize',ms,...
       'markeredgecolor','k','markerfacecolor',c2,...
       'color','w');
% plot(x,y,'color',c1,'linewidth',lw)
legend('G(i) = 0', 'G(i) = 1');
% set(legHandle,'color',legColor)
% set(legHandle,'FontWeight','bold')

%Dummy image
imagesc(data.t, 0:obj.nElec+1, zeros(length(data.t),2+obj.nElec))

%plot the image
imagesc(data.t(data.t>=0), 1:obj.nElec, transp(data.global(data.t>=0,:)));

%Set the Axis
set(gca, 'YTick', 1:obj.nElec)

%And the gridlines
theList = 0.5:1:obj.nElec+0.5;
for i=1:obj.nElec
    x=[data.t(1), data.t(end)];
    y=[theList(i), theList(i)];
    plot(x,y,'color',gridColor)
end

%The limits
xlim([data.t(1), data.t(end)])
ylim([0.5,obj.nElec+0.5])

%THe labels
xlabel(xlabelStr)
ylabel('Cell')
% 
% title('Global Transition')

colormap([c1;c2])