function M=cuttleIO(objOrName, data, frames)

%Set the frames if specified
if nargin==3
    data.frames=frames;
end

%%%%Sort out arguments
%First argument
if ischar(objOrName)
    name = objOrName;
    load (name)
else
    obj = objOrName;
    name = obj.name;
end

global movieName
movieName = obj.name;

% @(M, frame) structMovie(M, frame);
% @(M, frame) aviMovie(M, frame);
M=doAnimation(obj, data, @(M, frame) structMovie(M, frame));



%%%Movie structure
    function M=structMovie(M, frame)
        if strcmpi(M, 'init')
            M = struct('cdata',{},'colormap',{});
        elseif strcmpi(M, 'close')
            M = frame;
        else
            M(end+1) = frame;
        end
    end



%%%AVI movie
    function M = aviMovie(M, frame)
        
        %Create bmovie object
        if strcmpi('init',M)
            %%
            type = 'mp4';
            
            %Delete the movie if its already there
            if exist(movieName,'file')==2
                delete(movieName)
            end
            
            %Make the object
            M = VideoWriter(movieName, 'MPEG-4');
            
            
            %Open it
            open(M);
        elseif strcmpi('close',M)
            close(frame)
        else
            writeVideo(M,frame);
        end
    end
end



function output=doAnimation(obj, data, addFrame)
%%%Main Paramters
%The framerate
framerate = 20;

%The Speed
speed=10;

%The image
img = importBNP('laura_cuttle_coded2.bmp');

%colors - c1: passive, c2: Manual, c3: Self-sensing
c1 = [119,200,185];
c2 = [47 ,117,117];
c3 = c2;

%%%%%The picture
%Map:  192 - Punch Out
%      200 - Color 1
%      100 - Color 2
%      50  - Color 3

colors = {c1,c2,c3};
colorCode = [107, 161, 500];
punchCode = 64;

%The masked
mask = uint8(img==punchCode);
mask(:,:,2) = mask(:,:,1);
mask(:,:,3) = mask(:,:,1);


%Make 3D Image
s = [size(img),3];
img3D = zeros(s);
img3D(:,:,1) = img;
img3D(:,:,2) = img;
img3D(:,:,3) = img;

%color by number
for i=1:length(colorCode)
    img3D = colorByNumber(img3D, img, colorCode(i), colors{i});
end


%Make uint8
img3D= uint8(img3D);

%%%%Main Routine
%Generate animation data
data.framerate = framerate;
data.speed = speed;
if any(strcmp('frames',fieldnames(data)))
    aniData = genAnimationData(data, obj, data.frames);
else
    aniData = genAnimationData(data, obj);
end

%Initialise
output = addFrame('init',[]);



%Create figures
close all; hold on
stripesFigH=figure;
stripesAxH=axes;
set(stripesFigH, 'visible','off')
xlim(stripesAxH,[0, obj.theLength])
set(stripesAxH, 'LooseInset', [0,0,0,0]);
set(stripesFigH,'CurrentAxes',stripesAxH)




%Animation Loop
for i=1:1
    clc;fprintf('%.1f%% Complete',100*aniData.t(i)/aniData.t(end))
    
    cla(stripesAxH);
%     %plot each element
%     hold on;
%     
%     for j=1:obj.nElem
%         %The current color
%         currColor = colors{ 1 + aniData.elemType(j) } ./ 255;
%         
%         plotFilled(stripesAxH, aniData.theLine, aniData.start(i,j), aniData.end(i,j), currColor)
%     end
%     
%     %sort the axes
%     title(stripesAxH, sprintf('Time: %.2f', aniData.t(i)) )
%     set(stripesAxH,'XTick',[])
%     set(stripesAxH,'YTick',[])
%     sides=0.5;
%     xlim([-obj.theLength*(-0.2+sides), obj.theLength*(0.94+sides)])
    plotMat(obj.name, data);


    %Get a frame
    theFrame = getframe(stripesFigH);
    thresh =100;
    for i=1:3
        primaryColor = theFrame.cdata(:,:,i);
        primaryColor(primaryColor>thresh) = c1(i);
        primaryColor(primaryColor<=thresh) = c2(i);
        theFrame.cdata(:,:,i) = primaryColor;
    end
    
    rawFrame = theFrame;
    
    %Mask it
    theFrame.cdata = imresize(theFrame.cdata, size(img)) .* mask;
    
    %Add the bits that aren't the mask
    theFrame.cdata(~mask) = img3D(~mask);
    
    %Add the Frame
    output = addFrame(output, theFrame);
end
save debug
output = addFrame('close', output);
end




%Generate Data for animation
function aniData = genAnimationData(data, obj, frames)
%Interpolate the Data
if nargin==3
    t = frames;
else
    %The number of points
    nPts = (data.t(end) - data.t(1)) * data.framerate / data.speed;
    
    t = linspace(data.t(1),data.t(end),nPts);
end

disp = interp1(data.t, data.disp, t);

%Zero Displacement Positions of nodes
zeroDisp = linspace(0, obj.theLength, obj.nNodes);

%Position of the nodes as a function of time
pos = disp + ones(length(t),1) * zeroDisp;

%%%%Find each element type
%%0: undefined, 1: Manual, 2: Self-sensing
elemType = zeros(obj.nElem,1);
for i=1:obj.nElec
    currElem = obj.electrodes{i};
    elemType(currElem) = obj.elecType(i);
end

%%%%The line
P = [
    0,0;
    -2,0.8;
    1,1;
    ];


aniData.t=t;
aniData.theLine = bezQuad(P);
aniData.start = pos(:,1:end-1);
aniData.end = pos(:,2:end);
aniData.elemType = elemType;
end




%Plot a filled polygon, given a line, start and end
function plotFilled(handle, theLine, x1, x2, color)
x = [theLine(:,1) + x1; flipud(theLine(:,1) + x2)];
y = [theLine(:,2); flipud(theLine(:,2))];

fill(x,y,color, 'Parent', handle, 'EdgeColor', color)
end



%%%%%%%%A quadratic bezier
function theLine = bezQuad(P)

%The number of ppoints
nPts=100;

%The control points
if nargin==0
    P=[
        0,0;
        -1,0;
        2,2;
        ];
end

t=linspace(0,1,nPts);

%Generate the quadratic bezier
for i=1:length(t)
    currT = t(i);
    theLine(i,:)= (1-currT) .* ((1-currT).*P(1,:) + currT.*P(2,:))...
        + currT.*( (1-currT).*P(2,:)...
        + currT.*P(3,:) );
end

end



%%%Color by number
function img=colorByNumber(img, imgCode, num, color)
%The mask
mask = img == num;
mask(:,:,2) = mask(:,:,1);
mask(:,:,3) = mask(:,:,1);

%3D image size
s = [size(img), 3];

%A 3D block of color
colorBlock = zeros(s);
colorBlock(:,:,1) = color(1);
colorBlock(:,:,2) = color(2);
colorBlock(:,:,3) = color(3);

img(mask) = colorBlock(mask);

end