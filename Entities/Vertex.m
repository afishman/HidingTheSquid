classdef Vertex < handle
    %A VERTEX joins two elements, or an element to a boundary
    
    properties (SetAccess = public)
        %Displacement from origin
        Displacement;
        
        Velocity;

        Origin;
        
        %These will remain [] if attached to a boundary
        LeftElement=[];
        RightElement=[];
    end
    
    methods
        function this = Vertex(origin, displacement, velocity)
            this.Origin = origin;
            this.Displacement = displacement;
            this.Velocity = velocity;
        end
        
        function position = Position(this)
            position = this.Origin + this.Displacement;
        end
        
        %Returns [] if there is no next vertex
        function vertex = Next(this)
            if(isempty(this.RightElement))
                vertex = [];
            else
                vertex = this.RightElement.EndVertex;
            end
        end
        
        %Fixed boundary conditions imposed here
        function acceleration = Acceleration(this)
            if (isempty(this.RightElement) || isempty(this.LeftElement))
                acceleration = 0;
            else
                mass = (this.LeftElement.Mass + this.RightElement.Mass) / 2;
                acceleration = (this.LeftElement.Force - this.RightElement.Force)/mass;
            end
        end
    end
   
end

