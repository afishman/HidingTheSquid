function data = plotLambda(name, data)
% close all
%Load the data
if nargin==1
    data = loadData(name);
end

load([name,'.mat'])

%Find lambda
% lambda = obj.preStretch + diff(data.disp, 1, 2)./obj.L;

%Plot it
plot(data.t,data.lambda)

title('LAMBDA')
