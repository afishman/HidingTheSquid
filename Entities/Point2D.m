classdef Point2D < handle
    %Just a simple 2D point
    
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

