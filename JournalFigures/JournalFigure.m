classdef JournalFigure < handle & matlab.mixin.Heterogeneous
    properties
        
        JournalPath = '../Journal/Submission/';
        Format = 'epsc';
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
            set(gcf,'PaperPositionMode','auto')
            saveas(gcf, [this.JournalPath,this.Name], this.Format);
        end
    end
end