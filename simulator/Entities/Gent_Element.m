classdef Element < handle
    %GENT_ELEMENT is a small bit of material with constant stretch ratio
    %and internal properties
    %   This class is abstract to allow other 1D deformation models to be
    %   implemented. More abstraction could be done, but this is intended to
    %   reflect the equations written up in the paper
    
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

        %Should be a Gent_Model
        InternalStressModel;
        MaterialProperties;
        
        NaturalLength;
        NaturalWidth;
    end
    
    methods
        %Initialises an element at rest in prestretched configuration
        function this = Element( ...
            startVertex, ...
            endVertex, ...
            preStretch, ...
            naturalLength, ...
            naturalWidth, ...
            internalStressModel, ...
            materialProperties)

            %TODO: Add a check that the model is a gent
            if(isempty(internalStressModel))
                error('No model given to Element constructor')
            end
            
            if(isempty(materialProperties))
                error('No material properties given to Element constructor');
            end
            
            if(isempty(startVertex))
                error('Every Element must define a start vertex');
            end
            
            if(isempty(endVertex))
                error('Every Element must define a end vertex');
            end
            
            if(naturalLength <= 0 || naturalWidth<=0)
                error('all natural dimensions must be > 0')
            end

            this.InternalStressModel = internalStressModel;
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
            this.NaturalWidth = naturalWidth;
        end
        
        function thickness = NaturalThickness(this)
            thickness = this.MaterialProperties.NaturalThickness;
        end
        
        %Lambda is the stretch ratio (in length)
        function lambda = StretchRatio(this)
            lambda = this.PreStretch + (this.StartVertex.Displacement - this.EndVertex.Displacement)/this.NaturalLength;
        end
     
        function lambdaDot = StretchVelocity(this)
            lambdaDot = this.EndVertex.Velocity - this.StartVertex.Velocity;
        end
        
        
        
        %TODO: This should be refactorded whe considering other papers
        function length = Length(this)
            length = this.NaturalLength * this.StretchRatio;
        end
        
        %TODO: This should be refactorded whe considering other papers
        function length = Width(this)
            length = this.NaturalWidth * this.StretchRatio;
        end
        
        function thickness = Thickness(this)
            thickness = this.Volume / (this.Length * this.Width);
        end
        
        %Incompressibility assumptions makes this a constant
        function volume = Volume(this)
            volume = this.NaturalLength * this.NaturalWidth * this.NaturalThickness;
        end
        
        %TODO: This should include electrical stress
        function stress = Stress(this)
            stress =  this.ElectricalStress - this.InternalStressModel.Stress(this.StretchRatio, this.Xi);
        end
        
        function dXi = DXi(this)
            dXi = this.InternalStressModel.DXi(this.StretchRatio, this.Xi);
        end
        
        function capacitance = Capacitance(this)
            capacitance = (this.MaterialProperties.RelativeDielectricConstant ...
                * this.Length * this.Width) / this.Thickness;
        end
        
        %TODO: refactor when considering other papers - this is specific to
        %the thesis! (requires dLength, dWidth, dThickness plus some differentiation)
        function capDot = CapacitanceDot(this)
            capDot = 4 * this.StretchRatio.^3 * this.StretchVelocity * this.NaturalLength.^2 * this.NaturalThickness.^-1 * this.MaterialProperties.RelativeDielectricConstant;
        end
        
        %TODO: Should this be calculated here? Or in the RCCircuit?
        function dVoltage = DVoltage(this, switchClosed)
            if(isempty(this.RCCircuit))
                dVoltage = 0;
            else
                Vs = this.RCCircuit.SourceVoltage;
                V = this.Voltage;
                R = this.RCCircuit.Resistance;
                CDot = this.Resistance.CapacitanceDot;
                
                dVoltage = (Vs - switchClosed*V(1 + R*CDot)) / (R*C);
            end
        end
        
        function stress = ElectricalStress(this)
            stress = this.MaterialProperties.RelativeDielectricConstant * this.Voltage.^2 / this.Thickness.^2;
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
    end
    
end
