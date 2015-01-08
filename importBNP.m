function img2=importBNP(filename)

%%Import the image
[img,colormap]=imread(filename);

%Merge the colourmap
img2=zeros(size(img));

for i=1:size(colormap,1)
    img2(img == i-1) = mean(colormap(i,:).*255);
end

img2=uint8(img2);
