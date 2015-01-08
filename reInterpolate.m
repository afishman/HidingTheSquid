clear all

name = 'fig28d_2nV2';
rename = [name, '_1'];
ppS = 20;

%Delete
delete(rename)

%Open the file
id = fopen([name,'.txt'], 'r');

%The max number of points
ptsLim = 1000;

%Get the first Line
tLine = fgetl(id);
while tLine~=-1;
    %Chunks of data
    data=[];
    for i=1:ptsLim
        %Break if necessary
        if tLine == -1
            break
        end
        
        %Convert Line to number
        data=[data; str2num(tLine)];
        
        %Get the next one
        tLine = fgetl(id);
        
        if i>1 && (data(end,1)<=data(end-1,1))
            data(end,1)=data(end-1,1)+1e-5;
        end
    end
    
    %Interpolate
    nPts = round( ppS*(data(end,1) - data(1,1)) );
    t = linspace(data(1,1),data(end,1), nPts);
    data = interp1(data(:,1),data,t);
    
    %Append
    appendToFile(data, rename);
end
%Tidy
fclose(id);

%The mat file
load(name)
obj.name=rename;
save(rename, 'obj')
