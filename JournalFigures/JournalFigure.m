classdef JournalFigure < handle
    properties
        Name;
    end
    
    methods (Abstract)
        Generate;
    end
end