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
        
        %Thanks http://www.mathworks.com/matlabcentral/fileexchange/7465-getkey
        function [ch, tim] = GetKey(N,nonascii)
            
            % GETKEY - get a keypress
            %   CH = GETKEY waits for a single keypress and returns the ASCII code. It
            %   accepts all ascii characters, including backspace (8), space (32),
            %   enter (13), etc, that can be typed on the keyboard.
            %   Non-ascii keys (ctrl, alt, ..) return a NaN. CH is a double.
            %
            %   CH = GETKEY(N) waits for N keypresses and returns their ASCII codes.
            %   GETKEY(1) is the same as GETKEY without arguments.
            %
            %   GETKEY('non-ascii') or GETKEY(N,'non-ascii') uses non-documented
            %   matlab features to return a string describing the key pressed.
            %   In this way keys like ctrl, alt, tab etc. can also distinguished.
            %   The return is a string (when N = 1) or a cell array of strings.
            %
            %   [CH,T] = GETKEY(...) also returns the time between the start of the
            %   function and each keypress. This is, however, not that accurate.
            %
            %   This function is kind of a workaround for getch in C. It uses a modal,
            %   but non-visible window, which does show up in the taskbar.
            %   C-language keywords: KBHIT, KEYPRESS, GETKEY, GETCH
            %
            %   Examples:
            %
            %    fprintf('\nPress any key: ') ;
            %    ch = getkey ;
            %    fprintf('%c\n',ch) ;
            %
            %    fprintf('\nPress the Ctrl-key within 3 presses: ') ;
            %    ch = getkey(3,'non-ascii')
            %    if ismemmber('control', ch),
            %      fprintf('OK\n') ;
            %    else
            %      fprintf(' ... wrong keys ...\n') ;
            %    end
            %
            %  See also INPUT, UIWAIT
            %           GETKEYWAIT (File Exchange)
            
            % for Matlab 6.5 and higher
            % version 2.0 (jun 2012)
            % author : Jos van der Geest
            % email  : jos@jasen.nl
            %
            % History
            % 1.0 2005 - creation
            % 1.1 dec 2006 - modified lay-out and help
            % 1.2 apr 2009 - tested for more recent MatLab releases
            % 1.3 jan 2012 - modified a few properties, included check is figure still
            %            exists (after comment on FEX by Andrew).
            % 2.0 jun 2012 - added functionality to accept multiple key presses
            
            t00 = tic ; % start time of this function
            
            % check the input arguments
            error(nargchk(0,2,nargin))
            switch nargin
                case 0
                    nonascii = '' ;
                    N = 1 ;
                case 1
                    if ischar(N),
                        nonascii = N ;
                        N = 1 ;
                    else
                        nonascii = '' ;
                    end
            end
            
            if numel(N) ~= 1 || ~isnumeric(N) || N < 1 || fix(N) ~= N
                error('N should be a positive integer scalar.') ;
            end
            
            % Determine the callback string to use
            if strcmpi(nonascii,'non-ascii'),
                % non-ascii characters are accepted
                nonascii = true ;
                callstr = 'set(gcbf,''Userdata'',get(gcbf,''Currentkey'')) ; uiresume ' ;
            elseif isempty(nonascii)
                nonascii = false ;
                % only standard ascii characters are accepted
                callstr = 'set(gcbf,''Userdata'',double(get(gcbf,''Currentcharacter''))) ; uiresume ' ;
            else
                error('String argument should be the string ''non-ascii''') ;
            end
            
            % Set up the figure
            % May be the position property  should be individually tweaked to avoid visibility
            fh = figure(...
                'name','Press a key', ...
                'keypressfcn',callstr, ...
                'windowstyle','modal',...
                'numbertitle','off', ...
                'position',[0 0  1 1],...
                'userdata','timeout') ;
            try
                ch = cell(1,N) ;
                tim = zeros(1,N) ;
                
                % loop to get N keypresses
                for k=1:N
                    % Wait for something to happen, usually a key press so uiresume is
                    % executed
                    uiwait ;
                    tim(k) = toc(t00) ; % get the time of the key press
                    ch{k} = get(fh,'Userdata') ;  % and the key itself
                    if isempty(ch{k}),
                        if nonascii
                            ch{k} = NaN ;
                        else
                            ch{k} = '' ;
                        end
                    end
                end
                if ~nonascii
                    ch = [ch{:}] ;
                else
                    if N==1
                        ch = ch{1} ; % return as a string
                    end
                    % return as a cell array of strings
                end
            catch
                % Something went wrong, return empty matrices.
                ch = [] ;
                tim = [] ;
            end
            
            % clean up the figure, if it still exists
            if ishandle(fh)
                delete(fh) ;
            end
        end
    end
end

