classdef Point2D < handle
    %POINT2D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X;
        Y;
    end
    
    methods
        function this = Point2D(x,y)
            this.X = x;
            this.Y = y;
        end
        
        function Transpose(this, point)
            this.X = this.X + point.X;
            this.Y = this.Y + point.Y;
        end
    end
    
end

