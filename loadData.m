function [data, obj]=loadData(name, ppS, tRange)

%Sort out pps
if nargin==1
    ppS = 10e10;
end

%Get all the data if a time range isn't specified.
if nargin==3
    rangeSpecified=true;
else
    rangeSpecified=false;
end

% save debug
%Load the Object
load([name, '.mat'])

%%%Time studd
%How often to take a line
takeLinePeriod=1/ppS;

%The time sum
takeLineSum=ppS+1;

%The previous time
prevTime = 0;



%%%Open file
%Open the file
id = fopen([name '.txt'], 'r');



%%%%Get the data
tLine = 1;
rawData=[];
%Loop through unwanted time
if rangeSpecified
    %To get inside the loop
    tLineNum = tRange(1)-1;
    
    %Cyclethrough
    while (tLine(1)~=-1) & (tLineNum(1) < tRange(1))        
        %Get the next line
        tLine = fgetl(id);
        tLineNum=str2num(tLine);
    end

    %And add to raw data
    rawData=[rawData; tLineNum];
end



%Initialise for the while loop
count=0; countPeriod=0;
while tLine~=-1
    %Increase line count
    count=count+1;
    countPeriod=countPeriod+1;
    
    %Get the next line
    tLine = fgetl(id);
    
    %If we're not at the end
    if tLine~=-1
        tLineNum=str2num(tLine);
        
        %Add to tSum
        dT = tLineNum(1) - prevTime;
        takeLineSum = takeLineSum + dT;
        prevTime = tLineNum(1);
        
        
        %Get the data
        if (tLine~=-1) & ((takeLineSum>takeLinePeriod) | tLineNum(1)<=0)
            rawData = [rawData; tLineNum];
            
            %Reset sum
            takeLineSum=0;
        end
        
        %Print every 100
        if countPeriod==100
            clc; fprintf('Time Loaded: %.0fs\n',tLineNum(1))
            countPeriod=0;
        end
        
        %Break if necessary
        if rangeSpecified && (tLine(1)~=-1) && (tRange(2) <= tLineNum(1))
            break
        end
    end
end

%Close the file
fclose('all');

%Work out the number of elements
nCols = size(rawData,2);
nRows = size(rawData,1);

%Separate into a struct
start=1;

%Time;
output.t = rawData(:,start);
start=start+1;

%Displacement
output.disp = rawData(:, start:start+obj.nNodes-1);
start = start+obj.nNodes;

%Velocity
output.vel = rawData(:, start:start+obj.nNodes-1);
start = start+obj.nNodes;

%xi
output.xi = rawData(:, start:start+obj.nElem-1);
start = start+obj.nElem;

%V
output.V = rawData(:, start:start+obj.nElem-1);
start = start+obj.nElem;

%Global State
output.global = rawData(:, start:start+obj.nElec-1);


%%%%Make sur the Time field is monotonic increasing
for i=1:length(output.t)-1
    if output.t(i+1)-output.t(i)<=0
        output.t(i+1) = output.t(i)+1e-6;
    end
end


%%%Additonal data
clc;fprintf 'Calculating Additional Data...\n'

%Discrete global
output = getDiscrete(output);

%The strain sosurce

for i=1:nRows
    objTemp=setCurrCond(obj, rawData(i,1), rawData(i, 2:end-obj.nElec));
    [~,~,output.ss(i,:)] = objTemp.ss(objTemp);
end

%The stretch ratio
output.lambda = obj.preStretch + diff(output.disp, 1, 2)./obj.L;

data=output;






%%%%Get the discrete data
function output=getDiscrete(output)
%Get the first global state
prevState = output.global(1,:);
currState = prevState;

%The output list
output.discrete.t = output.t(1);
output.discrete.global(1,:) = currState;

%Go through the loop
for i=2:length(output.t)
    %Get the next global state
    currState = output.global(i,:);
    
    %Save if a change
    if ~isequal(currState, prevState)
        output.discrete.t = [output.discrete.t; output.t(i)];
        output.discrete.global = [output.discrete.global; output.global(i,:)];
    end
    
    %Reset the previous state
    prevState = currState;
end

