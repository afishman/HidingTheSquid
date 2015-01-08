classdef Vertex < handle
    %A VERTEX joins two elements
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        Displacement; % Zero Displacement is 
        Velocity;

        Origin; %Position of zero displacement in the prestretched configuration!
        LeftElement=[];
        RightElement=[];
    end
    
    methods
        %Origin is the position of zero displacement
        function this = Vertex(origin, displacement, velocity)
            this.Origin = origin;
            this.Displacement = displacement;
            this.Velocity = velocity;
        end
        
        function position = Position(this)
            position = this.Origin + this.Displacement;
        end
        
        function vertex = Next(this)
            if(isempty(this.RightElement))
                vertex = [];
            else
                vertex = this.RightElement.EndVertex;
            end
        end
        
        %Fixed boundary conditions imposed here
        function acceleration = Acceleration(this)
            if(isempty(this.RightElement) || isempty(this.LeftElement))
                acceleration = 0;
            else
                mass = (this.LeftElement + this.RightElement) / 2;
                acceleration = (this.LeftElement.Force - this.RightElement.Force)/mass;
            end
        end
    end
   
end

