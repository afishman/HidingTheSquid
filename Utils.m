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
    end
end

