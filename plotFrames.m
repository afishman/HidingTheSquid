function plotFrames(M)
close all
for i=1:length(M)
    figure
    imshow(M(i).cdata);
end
