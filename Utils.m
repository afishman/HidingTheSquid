classdef Utils
    %UTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        Tolerance = 1e-7;
    end
    
    methods (Static)
        function withinTol = WithinTolerance(a, b)
            withinTol = abs(a-b) < Utils.Tolerance;
        end
        
        %thanks: http://www.mathworks.com/matlabcentral/fileexchange/28559-order-of-magnitude-of-number
        function n = Order(val, base)
            %Order of magnitude of number for specified base. Default base is 10.
            %order(0.002) will return -3., order(1.3e6) will return 6.
            %Author Ivar Smith
            
            if nargin < 2
                base = 10;
            end
            n = floor(log(abs(val))./log(base));
        end
        
        %Write data to file
        function AppendToFile(data, filename)
            id = fopen(filename, 'a');
            
            %Loop over the data at each timestep
            for i=1:size(data,1)
                %Make the data for the line
                currData = data(i,:);
                
                %Initialise the line
                line=[];
                
                %Write the line
                for j=1:length(currData)
                    line=[line, sprintf('%e  ',currData(j))];
                end
                
                %Append to file
                fprintf(id, line);
                fprintf(id, '\r\n');
            end
            
            %Close the file
            fclose(id);
        end
        
        %returns true if a is approximately a multiple of b
        function isApprox = IsApproxMultipleOf(a, b)
            division = b / a;
            
            if(Utils.WithinTolerance(division, round(division)))
                isApprox = true;
            else
                isApprox = false;
            end
        end
        
        %sorts ascending
        function sorted = SortByKey(list, key)
            [~,ind] = sort(arrayfun(key, list));
            sorted = list(ind);
        end
        
        function item = MinByKey(list, key)
            [~, minIndex] = min(arrayfun(key, list));
            item = list(minIndex);
        end
        
        function item = MaxByKey(list, key)
            item = Utils.MinByKey(list, @(x) key(-x));
        end
        
        %returns the quadratic (x-a)^2 + b with roots x1 and x2
        function [a ,b] = QuadraticCoefficients(x1, x2)
            if(x1 == x2)
                error('Roots of the quadratic must be distinct!')
            end
            
            a = (x1^2 - x2^2)/(2*(x1 - x2));
            b = -(x2-a)^2;
        end
        
        function value = QuadraticFun(x, a, b)
            value = (x-a).^2 + b;
        end
        
        function lastLine = LastLineOfFile(name)
            %Open the file
            fid = fopen(name, 'r');
            lastLine = '';                   %# Initialize to empty
            offset = 1;                      %# Offset from the end of file
            fseek(fid,-offset,'eof');        %# Seek to the file end, minus the offset
            newChar = fread(fid,1,'*char');  %# Read one character
            while (~strcmp(newChar,char(10))) || (offset == 1)
                lastLine = [newChar lastLine];   %# Add the character to a string
                offset = offset+1;
                fseek(fid,-offset,'eof');        %# Seek to the file end, minus the offset
                newChar = fread(fid,1,'*char');  %# Read one character
            end
            fclose(fid);  %# Close the file
        end
    end
end

