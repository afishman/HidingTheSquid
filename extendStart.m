%Extend the start of the sim (assumes it is the same as the first line in
%the file!)

%%%%Main controls
name = 'one neighbour/oneNeighLong_30';     %The name of the sim
extendTime = 100;    %How long to extend it for
ppS=0.1;            %Points Per Second


%%%%Routine
%The new version
rename = [name, '_ext'];

%Load the Object
load(name);

%The number of lines to do at a time
nLines = 100;

%Save the rename
delete([rename, '.txt']);
save(rename,'obj');

%The files
oldFileId = fopen([name,'.txt'], 'r');
newFileId = fopen([rename, '.txt'], 'w');

%Get the first line
nextLine = fgetl(oldFileId);
nextLineNum = str2num(nextLine);

%Find the Start Time
tEnd= nextLineNum(1);

%And the Start time
tStart = tEnd - extendTime;

%%%Write the first line many times
%The number of points
nPts = round(ppS*extendTime);

%The Times
t = linspace(tStart, tEnd, nPts);

%The data matrix
data = repmat(nextLineNum, nPts, 1);
data(:,1) = t;
data(:,end-obj.nElec+1)=0;

%Append To File
appendToFile(data, rename)


%Get the other lines
nextLine = fgetl(oldFileId);
while nextLine~=-1
    data=[];
    
    for i=1:nLines
        %Setup
        nextLineNum = str2num(nextLine);
        
        %Add to data
        data = [data; nextLineNum];
        
        %Get the Next Line
        nextLine=fgetl(oldFileId);
        
        if nextLine == -1
            break
        end
    end
    
    %Append to file
    if ~isempty(data)
        appendToFile(data, rename)
    end
    
    %Update
    clc;fprintf('Time: %.0fs\n', nextLineNum(1));
end


fclose(oldFileId);
fclose(newFileId);