clear all
clc

%The two files (in ascending time order)
file1 = 'fig27';
file2 = 'fig27_1s';
fileOut = 'fig27_1s1';

%Load the files
id1 = fopen([file1,'.txt'], 'r');
id2 = fopen([file2,'.txt'], 'r');

%Read the first line of id2
file2Line1 = fgetl(id2);
file2Line1Num = str2num(file2Line1);

%The transition time
tEnd = file2Line1Num(1);

%Get the next line of the second file
currLine = fgetl(id1);
currT = currLine(1);

%%%Copy the first file
data=[];
while (currT<tEnd) && (currLine(1)~=-1)
    %Convert to number
    currLineNum = str2num(currLine);
    
    %Add to data
    data = [data; currLineNum];
    
    %Get the next line of the first file
    currLine = fgetl(id1);
    
    currT = currLineNum(1);
end

%%%Copy the second
%Add the first line
data=[data;file2Line1Num];

%Get the next line of the first file
currLine = fgetl(id2);
currT = currLine(1);

while currLine~=-1
    %Convert to number
    currLineNum = str2num(currLine);
    
    %Add to data
    data = [data; currLineNum];
    
    %Get the next line of the first file
    currLine = fgetl(id2);
    currT = currLine(1);
end

%Append
appendToFile(data, fileOut);

fclose('all');