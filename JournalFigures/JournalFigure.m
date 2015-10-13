classdef JournalFigure < handle & matlab.mixin.Heterogeneous
    properties
        
        JournalPath = '../Journal/Submission/';
        Format = 'epsc';
    end
    
    properties (Constant)
        CuttleTextAdjustment = 2.4
        LegendTextAdjustment = 0.7;
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
            this.PostProcessFigure;
            saveas(gcf, [this.JournalPath,this.Name], this.Format);
        end
       
        function PostProcessFigure(this)
            JournalFigure.AdjustFont(1.4);
            set(gcf,'PaperPositionMode','auto');
    end
            
        
    end
    
    methods(Static)
        function AdjustFont(prop)
            fonts = findall(gcf,'-property','FontSize');
            
            for i = 1:length(fonts)
                font = fonts(i);
                
                currentSize = get(font, 'FontSize');
                set(font, 'FontSize', currentSize*prop);
            end
        end
    end
end