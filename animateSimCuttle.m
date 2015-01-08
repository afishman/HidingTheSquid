function M=animateSim(objOrName, data)

%%%Main Paramters
%The framerate
framerate = 20;

%The Speed
speed=10;

%Linewdith
linewidth=1000;

%The picture
img = importBNP('cuttlefishCoded2.bmp');
mask = uint8(img==192);
notMask = ~mask;
mask(:,:,2) = mask(:,:,1);
mask(:,:,3) = mask(:,:,1);


%%%%Sort out arguments
%First argument
if ischar(objOrName)
    name = objOrName;
else
    obj = objOrName;
    name = obj.name;
end

%Second Argument
if nargin==1
    data = loadData(name);
end


%%%%Main Routine
%Load the object
load(name)

%Generate animation data
data.framerate = framerate;
data.speed = speed;
aniData = genAnimationData(data, obj);

%Create figures
close all; hold on
stripesFigH=figure;
stripesAxH=axes;
set(stripesFigH, 'visible','off')
xlim(stripesAxH,[0, obj.theLength])
set(stripesAxH, 'LooseInset', [0,0,0,0]);
set(stripesFigH,'CurrentAxes',stripesAxH)

%Animation Loop
for i=1:length(aniData.t)
    cla(stripesAxH)
    
    if ~isempty(aniData.undef)
        %Plot the undefined nodes
        plot(stripesAxH,aniData.undefX(:,:,i), aniData.undefY(:,:,i), 'k','linewidth',linewidth);
    end
    
    if ~isempty(aniData.manu)
        %Plot the undefined nodes
        plot(stripesAxH,aniData.manuX(:,:,i), aniData.manuY(:,:,i), 'r','linewidth',linewidth);
    end
    
    if ~isempty(aniData.self)
        %Plot the undefined nodes
        plot(stripesAxH,aniData.selfX(:,:,i), aniData.selfY(:,:,i), 'b','linewidth',linewidth);
    end
    
    %The time
    title(stripesAxH, sprintf('Time: %.2f', aniData.t(i)) )
    set(stripesAxH,'XTick',[])
    set(stripesAxH,'YTick',[])
    
    %Get a frame
    theFrame = getframe(stripesFigH);
    rawFrame(i) = theFrame;
    
    %Mask it
    theFrame.cdata = imresize(theFrame.cdata, size(img)) .* mask;
    
    %Add the bits that aren't the mask
    theFrame.cdata(notMask) = img(notMask);

    M(i)=theFrame;
%     save debug
    
%     pause(1/framerate)
end
end




%Generate Data for animation
function aniData = genAnimationData(data, obj)
%The number of points
nPts = (data.t(end) - data.t(1)) * data.framerate / data.speed;

%Interpolate the Data
t = linspace(data.t(1),data.t(end),nPts);
disp = interp1(data.t, data.disp, t);

%ZeroDisplacement Positions of nodes
zeroDisp = linspace(0, obj.theLength, obj.nNodes);

%Position of the nodes as a function of time
pos = disp + ones(length(t),1) * zeroDisp;

%Membrane, Undefined electrode, Manual, Self-sensings
undef=[];manu=[]; self=[];
for i=1:obj.nElec
    currElec = [obj.electrodes{i}(1), obj.electrodes{i}(end)+1];
    
    %Sort ot for plotting
    if obj.elecType(i) == 0
        undef(:,end+1) = currElec;
    elseif obj.elecType(i) == 1
        manu(:,end+1) = currElec;
    else
        self(:,end+1) = currElec;
    end
end

%Setup the x's
if ~isempty(undef)
    undefX(1,:,:) = pos(:, undef(1,:))';
    undefX(2,:,:) = pos(:, undef(2,:))';
    undefY = zeros(size(undefX));
    
    aniData.undefX = undefX;
    aniData.undefY = undefY;
end
if ~isempty(manu)
    manuX(1,:,:) = pos(:, manu(1,:))';
    manuX(2,:,:) = pos(:, manu(2,:))';
    manuY = zeros(size(manuX));
    aniData.manuX = manuX;
    aniData.manuY = manuY;
end
if ~isempty(self)
    selfX(1,:,:) = pos(:, self(1,:))';
    selfX(2,:,:) = pos(:, self(2,:))';
    selfY = zeros(size(selfX));
    aniData.selfX = selfX;
    aniData.selfY = selfY;
end

aniData.undef = undef;
aniData.manu = manu;
aniData.self = self;
aniData.t = t;



end
