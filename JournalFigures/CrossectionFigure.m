classdef CrossectionFigure < JournalFigure
    properties
        Name =  'CrossectionFigure';
        Thread;
        ActiveLabel;
        PassiveLabel;
    end
    
    methods
        function this = CrossectionFigure(thread, name, activeLabel, passiveLabel)
            this@JournalFigure;
            
            this.Thread = thread;
            this.Name = name;
            this.ActiveLabel = activeLabel;
            this.PassiveLabel = passiveLabel;
        end

        function Generate(this) 
            h = figure;
            
            set(h, 'Position', [290, 615, 710, 183]);
            
            hold on
            linewidth = 40;
            
            passiveColor = 0.7.*[1, 1, 1];
            activeColor = 'k';
            
            plot([0,0], [0,0], 'Color', passiveColor, 'LineWidth', linewidth/10);
            plot([0,0], [0,0], 'Color', activeColor, 'LineWidth', linewidth/10);
            
            
            leg = legend({'Membrane', 'Electrode'});
            legSize = get(leg, 'FontSize');
            set(leg, 'FontSize', legSize*0.6);
            %plot([thread.StartVertex.Position, thread.EndVertex.Position], [0,0], passiveColor, 'LineWidth', linewidth);
            
            xticks=[0];
            
            naturalThickness = 1;
            fudgeFactor = 0.002;
            center = 0.5;
            
            for electrode = this.Thread.Electrodes
                startX = electrode.StartVertex.Position;
                width =  electrode.EndVertex.Position - electrode.StartVertex.Position - fudgeFactor;
                
                height = naturalThickness/(electrode.StretchRatio);
                startY = center - height/2;
                rectangle('Position',[startX, startY, width, height], 'FaceColor', activeColor,'EdgeColor', activeColor)
                
                xticks(end+1) = electrode.EndVertex.Position;
                
                if(~isempty(electrode.EndVertex.RightElement))
                    elements = this.Thread.GetPassiveSection(electrode.EndVertex.RightElement);
                    
                    startX = elements(1).StartVertex.Position;
                    width =  elements(end).EndVertex.Position - elements(1).StartVertex.Position - fudgeFactor;
                    height = naturalThickness/(elements(1).StretchRatio);
                    startY = center - height/2;
                    
                    rectangle('Position',[startX, startY, width, height], 'FaceColor', passiveColor,'EdgeColor', passiveColor);
                    
                    
                    xticks(end+1) = elements(end).EndVertex.Position;
                end
            end
            
            showElectrodeLabel = true;
            for(i=1:length(xticks)-1)
                xpos = mean([xticks(i), xticks(i+1)]);
                
                if(showElectrodeLabel)
                    textString = this.ActiveLabel;
                else
                    textString = this.PassiveLabel;
                end
                
                text(xpos, -0.7, textString, 'HorizontalAlignment', 'Center');
                
                showElectrodeLabel = ~showElectrodeLabel;
            end
            
            
            set(gca, 'YTick', []);
            set(gca, 'XTick', xticks);
            set(gca, 'XTickLabel', [])
            ylim([-1,2])
            grid on
            box on
        end
        
        
    end
end

