function data = plotSS(name, data)
% close all
hold on
%Load the data
if nargin==1
    data = loadData(name);
end
load(name)

%Find lambda
% lambda = obj.preStretch + diff(data.disp, 1, 2)./obj.L;

%Plot it
plot(data.t,data.ss)

%Plot the Legend
for i=1:obj.nElec
    legendStrings{i}=sprintf('Cell %i',i);
end
legendStrings{end+1}='Switching Threshold';

%The limits
xLimits = [data.t(1), data.t(end)];
xlim(xLimits);
ylim([1,5.5]);

%And threshold crossings
for i=1:length(obj.thresh)
    plot(xLimits, [obj.thresh(i), obj.thresh(i)], 'k--')
end

%Show the legend
legend(legendStrings)
xlabel('Time (s)')
ylabel('Strain Source')
% title('STRAIN SOURCE')