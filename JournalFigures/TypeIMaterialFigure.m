classdef TypeIMaterialFigure < SimFigure
    properties
        Name =  'typeIMaterial';
    end
    
    methods
        function this = TypeIMaterialFigure(viewer)
            this@SimFigure(viewer);
        end
    
        
        function Generate(this)
            f = figure;
            this.Viewer.PlotMaterial
            
            yLimits = [0.12, 0.23];
            ylim(yLimits)
            
            annotation(f,'ellipse',...
    [0.197428571428571 0.671428571428573 0.668642857142857 0.185714285714292],...
    'LineWidth',3,...
    'Color',[1 0 0]);


% Create textarrow
y = 0.21;
a = annotation(f,'textarrow',[0.105357142857143 0.169642857142857],...
    [y, y],'TextEdgeColor','none',...
    'String',{'Passive','Region'});

fontSize = get(a, 'FontSize') *0.7;
set(a, 'FontSize', fontSize);

% % % Create textarrow
y = 0.8;
a = annotation(f,'textarrow',[0.105357142857143 0.169642857142857],...
     [y, y],'TextEdgeColor','none',...
     'String',{'Passive','Region'});
set(a, 'FontSize', fontSize);
 
 
 % % % Create textarrow
y = 0.65;

  a = annotation(f,'textarrow',[0.105357142857143 0.169642857142857],...
     [y, y],'TextEdgeColor','none', ...
     'Color', 'w');
 set(a, 'FontSize', fontSize);
 
 a= annotation(f,'textarrow',[0.105357142857143 0.13],...
     [y, y],'TextEdgeColor','none',...
     'String',{'Cell'}, ...
     'HeadLength',0,...
    'HeadWidth',0);
set(a, 'FontSize', fontSize);
 



% The the lines
states = this.Viewer.InterpolateRawData([0,25]);
states(1).SetState;

whiteRange1 = [states(1).Thread.Electrodes(1).StartVertex.Position, states(1).Thread.Electrodes(1).EndVertex.Position];

states(2).SetState;
whiteRange2 = [states(2).Thread.Electrodes(1).StartVertex.Position, states(2).Thread.Electrodes(1).EndVertex.Position];


yHeight = yLimits(2) - 0.95*(yLimits(2) - yLimits(1));
linewidth = 2;
plot([0,0],yLimits,'-.k', 'LineWidth', linewidth)
plot([0,0],whiteRange1,'-.w', 'LineWidth', linewidth)
a = text(0.0, yHeight, 'Source Voltage Applied');
set(a, 'FontSize', fontSize);

%get the limits at 0 and 1



plot([25,25],yLimits,'-.k', 'LineWidth', linewidth)
plot([25, 25],whiteRange2,'-.w', 'LineWidth', linewidth)
a = text(25.0, yHeight, 'Source Voltage Removed');
set(a, 'FontSize', fontSize);





        end
    end
end

