classdef SimAnimator
    %SIMANIMATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Viewer;
    end
    
    methods
        function this=SimAnimator(viewer)
            this.Viewer = viewer;
        end
        
        function MakeMovie
        end
        
        %%%%%%%%A quadratic bezier
        function linePoints = bezQuad(this)
            
            %The number of ppoints
            nPts=100;
            
            %The control points
            P=[
                0,0;
                -1,0;
                2,2;
                ];
            
            t=linspace(0,1,nPts);
            
            linePoints = Point2D.empty;
            
            %Generate the quadratic bezier
            for i=1:length(t)
                currT = t(i);
                point = (1-currT) .* ((1-currT).*P(1,:) + currT.*P(2,:))...
                    + currT.*( (1-currT).*P(2,:)...
                    + currT.*P(3,:) );
                
                linePoints(end+1) = Point2D(point(1), point(2));
            end
            
        end
        
        %Plot a filled polygon, given a line, start and end
        function PlotFilled(this)
            handle = gca;
            x1 = 0;
            x2 = 1;
            color = 'r';
            
            theLine = this.bezQuad;
            
            firstHalf = this.bezQuad;
            shift = Point2D(x1, 0);
            arrayfun(@(x) x.Transpose(shift), firstHalf);
            
            shift = Point2D(x2, 0); 
            secondHalf = fliplr(this.bezQuad);
            arrayfun(@(x) x.Transpose(shift), secondHalf);
           
            polygonPoints = [firstHalf, secondHalf];
            
            x = arrayfun(@(x) x.X, polygonPoints);
            y = arrayfun(@(x) x.Y, polygonPoints);
                
            fill(x,y,color, 'Parent', handle, 'EdgeColor', color)
        end
        
    end
    
end

