classdef Utils
    % A static collecion of bits and bobs
    
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
        
        %Append two dimensional data to a file, separating with spaces
        %TODO: Use a better delimiter than spaces
        function AppendToFile(data, filename)
            if ~ismatrix(data)
                error('Dimensionality of data when appending to a file must be 2!');
            end
            
            id = fopen(filename, 'a');
            
            try
                %Loop over each row of data
                for i=1:size(data,1)
                    currData = data(i,:);
                    
                    %Write the line
                    line=[];
                    for j=1:length(currData)
                        line=[line, sprintf('%e  ',currData(j))];
                    end
                    
                    %Append to file
                    fprintf(id, line);
                    fprintf(id, '\r\n');
                end
                
                %Close the file
                fclose(id);
                
            catch ex
                %Ensure the file closed.
                fclose(id);
                rethrow(ex);
            end
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
        
        %Thanks: http://stackoverflow.com/questions/2659375/matlab-command-to-access-the-last-line-of-each-file
        function lastLine = LastLineOfFile(name)
            %Open the file
            fid = fopen(name, 'r');
            
            try
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
                
            catch ex
                fclose(fid);  %# Close the file
                rethrow(ex)
            end
        end
        
        %Returns a string with the same characters as the old until the key
        %returns true
        function newString = TakeCharsUntilTrue(oldString, key)
            newString = [];
            
            for c = oldString
                if(key(c))
                    break;
                end
                
                newString(end+1) = c;
            end
        end
        
        %Thanks http://www.mathworks.com/matlabcentral/fileexchange/26212-round-with-significant-digits
        function y=RoundSigFigs(x,n,method)
            %ROUNDSD Round with fixed significant digits
            %	ROUNDSD(X,N) rounds the elements of X towards the nearest number with
            %	N significant digits.
            %
            %	ROUNDSD(X,N,METHOD) uses following methods for rounding:
            %		'round' - nearest (default)
            %		'floor' - towards minus infinity
            %		'ceil'  - towards infinity
            %		'fix'   - towards zero
            %
            %	Examples:
            %		roundsd(0.012345,3) returns 0.0123
            %		roundsd(12345,2) returns 12000
            %		roundsd(12.345,4,'ceil') returns 12.35
            %
            %	See also Matlab's functions ROUND, ROUND10, FLOOR, CEIL, FIX, and
            %	ROUNDN (Mapping Toolbox).
            %
            %	Author: François Beauducel <beauducel@ipgp.fr>
            %	  Institut de Physique du Globe de Paris
            %
            %	Acknowledgments: Edward Zechmann, Daniel Armyr, Yuri Kotliarov
            %
            %	Created: 2009-01-16
            %	Updated: 2014-11-14
            
            %	Copyright (c) 2014, François Beauducel, covered by BSD License.
            %	All rights reserved.
            %
            %	Redistribution and use in source and binary forms, with or without
            %	modification, are permitted provided that the following conditions are
            %	met:
            %
            %	   * Redistributions of source code must retain the above copyright
            %	     notice, this list of conditions and the following disclaimer.
            %	   * Redistributions in binary form must reproduce the above copyright
            %	     notice, this list of conditions and the following disclaimer in
            %	     the documentation and/or other materials provided with the distribution
            %
            %	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
            %	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
            %	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
            %	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
            %	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
            %	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
            %	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
            %	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
            %	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
            %	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
            %	POSSIBILITY OF SUCH DAMAGE.
            
            if nargin < 2
                error('Not enough input arguments.')
            end
            
            if nargin > 3
                error('Too many input arguments.')
            end
            
            if ~isnumeric(x)
                error('X argument must be numeric.')
            end
            
            if ~isnumeric(n) | ~isscalar(n) | n < 0 | mod(n,1) ~= 0
                error('N argument must be a scalar positive integer.')
            end
            
            opt = {'round','floor','ceil','fix'};
            
            if nargin < 3
                method = opt{1};
            else
                if ~ischar(method) | ~ismember(opt,method)
                    error('METHOD argument is invalid.')
                end
            end
            
            % --- the generic formula was:
            %og = 10.^(floor(log10(abs(x)) - n + 1));
            %y = feval(method,x./og).*og;
            
            % --- but to avoid numerical noise, we must treat separately positive and
            % negative exponents, because:
            % 3.55/0.1 - 35.5 is -7.105427357601e-15
            % 	3.55*10 - 35.5 is 0
            e = floor(log10(abs(x)) - n + 1);
            og = 10.^abs(e);
            if e >= 0
                y = feval(method,x./og).*og;
            else
                y = feval(method,x.*og)./og;
            end
            
            y(x==0) = 0;
            
        end
        
        function img = ImportBMPIntoBW(path)
            %%Import the image
            [rawImg,colormap]=imread(path);
            
            %Merge the colourmap
            img=zeros(size(rawImg));
            
            for i=1:size(colormap,1)
                img(rawImg == i-1) = mean(colormap(i,:).*255);
            end
            
            img=uint8(img);
        end
    end
end

