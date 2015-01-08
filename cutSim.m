clear all

%%%Main parameters
%Name And Rename
name = 'oneNeighLong';
rename = 'oneNeighLong_paper';

%Cut etc...
tCut = 1200;

%%%Routine
%Minor parameter
nLines=100;

%Load the object
load(name);

%Save it
obj.name = rename;
save(rename, 'obj');

%Prepare for output
idIn = fopen([name,'.txt'], 'r');
delete(rename)

currT=-1e9;

%Get the other lines
nextLine = fgetl(idIn);
while (nextLine~=-1) & (currT<tCut)
    data=[];
    
    for i=1:nLines
        %Setup
        nextLineNum = str2num(nextLine);
        currT = nextLineNum(1);
        
        %Add to data
        data = [data; nextLineNum];
        
        %Get the Next Line
        nextLine=fgetl(idIn);
        
        if (nextLine == -1) | (nextLineNum(1)>tCut)
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



% %Loop through the data and copy
% line = fgetl(idIn); data=[];
% while line~=-1
%     %Vonvert ti numbers
%     lineNum = str2num(line);
%     
%     %Break if necessary
%     if lineNum(1)>tCut
%         break
%     end
%     
%     %Add to Data
%     data=[data; lineNum];
%     
%     %Get the next line
%     line = fgetl(idIn);
% end

%Append
fclose('all');
