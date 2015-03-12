classdef JournalFigure < handle & matlab.mixin.Heterogeneous
    properties
        
        JournalPath = '../Journal/Submission/';
        Format = '-depsc';
    end
    
    properties(Abstract)
        Name;
    end
    
    methods (Abstract)
        Generate(this);
    end
    
    
    methods
        function WriteToFile(this)
            close all;
            this.Generate;
            print([this.JournalPath,this.Name], this.Format);
        end
    end
end