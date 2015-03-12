classdef JournalFigureStub < JournalFigure
    %JOURNALFIGURESTUB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name = 'stub';
    end
    
    methods
        function Generate(this)
            plot(1:2,1:2);
        end
    end
    
end

