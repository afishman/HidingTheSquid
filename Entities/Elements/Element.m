classdef Element < handle & matlab.mixin.Heterogeneous
    %GENT_ELEMENT is a small bit of material with constant stretch ratio
    %and internal properties
    %   This class is abstract to allow other 1D deformation models to be
    %   implemented. More abstraction could be done, but this is intended to
    %   reflect the equations written up in the paper
    %
    %   Implementing new models (such as fiber constrained) should be as
    %   simple as inheriting from this class
    
    %TODO: DRY this up with Gent model
    properties
        Xi;
        Voltage;
        RCCircuit = []; %Should be set by the electrode
    end
    
    properties (SetAccess = private)
        StartVertex;
        EndVertex;
        
        PreStretch;
        
        MaterialProperties;
        
        NaturalLength;
        
        %TODO: This should probably be in an object, but whatevs
        MuA=25000;
        MuB=70000;
        Ja=90;
        Jb=30;
        Tau=0.01;
    end
    
    methods
        %Initialises an element at rest in prestretched configuration
        function this = Element( ...
                startVertex, ...
                endVertex, ...
                preStretch, ...
                naturalLength, ...
                materialProperties)
            
            
            if(isempty(materialProperties))
                error('No material properties given to Element constructor');
            end
            
            if(isempty(startVertex))
                error('Every Element must define a start vertex');
            end
            
            if(isempty(endVertex))
                error('Every Element must define a end vertex');
            end
            
            if(naturalLength <= 0)
                error('naturalLength must be > 0')
            end
            
            this.MaterialProperties = materialProperties;
            
            %set connections
            this.StartVertex = startVertex;
            this.EndVertex = endVertex;
            
            this.StartVertex.RightElement = this;
            this.EndVertex.LeftElement = this;
            
            %Initialise to prestretch config
            this.Xi = preStretch;
            this.PreStretch = preStretch;
            
            this.Voltage = 0;
            
            this.NaturalLength = naturalLength;
        end
        
        function thickness = NaturalThickness(this)
            thickness = this.MaterialProperties.NaturalThickness;
        end
        
        %Lambda is the stretch ratio (in length)
        function lambda = StretchRatio(this)
            lambda = this.PreStretch + (this.EndVertex.Displacement - this.StartVertex.Displacement)/this.NaturalLength;
        end
        
        function lambdaDot = StretchVelocity(this)
            lambdaDot = this.EndVertex.Velocity - this.StartVertex.Velocity;
        end
        
        function length = Length(this)
            length = this.NaturalLength * this.StretchRatio;
        end
        
        function thickness = Thickness(this)
            thickness = this.Volume / (this.Length * this.Width);
        end
        
        %Incompressibility assumptions makes this a constant
        function volume = Volume(this)
            volume = this.NaturalLength * this.NaturalWidth * this.NaturalThickness;
        end
        
        function area = LengthFaceArea(this)
            area = this.Width * this.Thickness;
        end
        
        %This is the force in the length direction
        function force = Force(this)
            force = this.Stress * this.LengthFaceArea;
        end
        
        function mass = Mass(this)
            mass = this.MaterialProperties.Density * this.Volume;
        end
        
        function stress = Stress(this)
            stress =  this.ElectricalStress - this.MaterialStress;
        end
        
        function stress = ElectricalStress(this)
            stress = this.MaterialProperties.RelativeDielectricConstant * this.Voltage.^2 / this.Thickness.^2;
        end
        
        function dVoltage = DVoltage(this, switchClosed)
            if(isempty(this.RCCircuit))
                dVoltage = 0;
            else
                Vs = this.RCCircuit.SourceVoltage;
                V = this.Voltage;
                R = this.RCCircuit.Resistance;
                C = this.Capacitance;
                CDot = this.CapacitanceDot;
                
                
                dVoltage = (switchClosed*Vs  - V*(1 + R*CDot)) / (R*C);
            end
        end
       
        function eta = Eta(this)
            eta = 6 * this.Tau * this.MuB;
        end
        
    end
    
    %I think this is what will need to be changed when extending the model
    methods (Abstract)
        
        
        capacitance = Capacitance(this);
        width = Width(this);
        naturalWidth = NaturalWidth(this);
        capDot = CapacitanceDot(this);
        
        stress = MaterialStress(this);
        dXi = DXi(this);
    end
end
