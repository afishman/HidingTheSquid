function animateSim(objOrName, data)

img=imread('cuttlefishCoded.bmp');

%%%Main Paramters
%The framerate
framerate = 20;

%The Speed
speed = 10;

%Linewdith
linewidth=100;

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

%The number of points
nPts = (data.t(end) - data.t(1)) * framerate / speed;

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
end
if ~isempty(manu)
    manuX(1,:,:) = pos(:, manu(1,:))';
    manuX(2,:,:) = pos(:, manu(2,:))';
    manuY = zeros(size(manuX));
end
if ~isempty(self)
    selfX(1,:,:) = pos(:, self(1,:))';
    selfX(2,:,:) = pos(:, self(2,:))';
    selfY = zeros(size(selfX));
end

clear disp

%Animation Loop
close all; hold on
xlim([0, obj.theLength])
for i=1:length(t)
    cla
    
    if ~isempty(undef)
        %Plot the undefined nodes
        plot(undefX(:,:,i), undefY(:,:,i), 'k','linewidth',linewidth);
    end
    
    if ~isempty(manu)
        %Plot the undefined nodes
        plot(manuX(:,:,i), manuY(:,:,i), 'r','linewidth',linewidth);
    end
    
    if ~isempty(self)
        %Plot the undefined nodes
        plot(selfX(:,:,i), selfY(:,:,i), 'b','linewidth',linewidth);
    end
    
    %The time
    title( sprintf('Time: %.2f', t(i)) )
    
    pause(1/framerate)
end


function genAnimationData(data, obj)
    
    
end
