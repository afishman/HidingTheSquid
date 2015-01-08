clear all
clc


name = 'conwayXL_20sBin';
[data, obj]=loadData(name, 1, [0,3000]);

%%
frames = [0, 50, 100, 180, 200, 250];

M=animateSim(obj, data, frames);

close all

for i=1:length(M)
    subplot(2,3,i)
    image(M(i).cdata)
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    
    label = sprintf('t = %is',frames(i));
    xlabel(label)
end
