classdef Element < handle & matlab.mixin.Heterogeneous
    %An ELEMENT is a small bit of material with constant stretch ratio
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
    
    %The default voltage is calculated as the optimal
    properties (Constant)
        DefaultResistance = 500; %In ohms
    end
    
    properties % (SetAccess = private)
        StartVertex;
        EndVertex;
        
        PreStretch;
        
        MaterialProperties;
        
        NaturalLength;
        
        GentParams;
    end
    
    methods
        %Initialises an element at rest in prestretched configuration
        function this = Element(elementInitParams)
            this.StartVertex = elementInitParams.StartVertex;
            this.EndVertex = elementInitParams.EndVertex;
            this.PreStretch = elementInitParams.PreStretch;
            this.NaturalLength = elementInitParams.NaturalLength;
            this.MaterialProperties = elementInitParams.MaterialProperties;
            this.GentParams = elementInitParams.GentParams;
            
            if(isempty(this.MaterialProperties))
                error('No material properties given to Element constructor');
            end
            
            if(isempty(this.StartVertex))
                error('Every Element must define a start vertex');
            end
            
            if(isempty(this.EndVertex))
                error('Every Element must define a end vertex');
            end
            
            if(this.NaturalLength <= 0)
                error('naturalLength must be > 0')
            end
            
            this.StartVertex.RightElement = this;
            this.EndVertex.LeftElement = this;
            
            %Initialise to prestretch config
            this.Xi = this.PreStretch;
            this.PreStretch = this.PreStretch;
            this.Voltage = 0;
        end
        
        function thickness = NaturalThickness(this)
            thickness = this.MaterialProperties.NaturalThickness;
        end
        
        %Lambda is the stretch ratio (in length)
        function lambda = StretchRatio(this)
            lambda = this.PreStretch + (this.EndVertex.Displacement - this.StartVertex.Displacement)/this.NaturalLength;
        
            %TODO: put these limits in a better place
            %Limiting stretch ratio of 6 is commonly used, see Dielectric Elastomers as Electromechanical Transducers
            if(lambda > 6)
                error('Limiting stretch reached');
                
                %Somewhat arbitrary
            elseif(lambda < 0.8)
                error('compression')
            end
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
            eta = this.GentParams.Tau * this.GentParams.MuB;
        end
        
        function SetStretchRatioAndXi(this, stretchRatio)
            this.SetStretchRatio(stretchRatio);
            this.Xi = stretchRatio;
        end
        
        %by adjusting the end vertex displacement
        function SetStretchRatio(this, stretchRatio)
            stretchDisplacement = stretchRatio - this.PreStretch;
            this.EndVertex.Displacement = this.StartVertex.Displacement + stretchDisplacement * this.NaturalLength;
        end
        
        function element = NextElement(this)
            element = this.EndVertex.RightElement;
        end
        
        function isElectroded = IsElectroded(this)
            isElectroded = ~isempty(this.RCCircuit);
        end
    end
    
    %I think this is what will need to be changed when extending the model
    methods (Abstract)
        capacitance = Capacitance(this);
        width = Width(this);
        naturalWidth = NaturalWidth(this);
        capDot = CapacitanceDot(this);
        rcCircuit = DefaultRCCircuit(this);
    end
    
    methods (Static, Abstract)
        stress = MaterialStress(this, gentParams);
        dXi = DXi(this, gentParams);
    end
    
    methods(Static)
        
       %plots an element's steady state stress against stretch ratio 
       function Demo(element)
            nPts = 100;
            lambdas = linspace(0.8,7,nPts);
            xis = linspace(0.8,7,nPts);
            
            element.NaturalLength = 1;
            element.StartVertex = Vertex(0,0,0);
            element.EndVertex = Vertex(1,0,0);
            
            stresses = [];
            actualStretches = [];
            
            for lambda = lambdas
                element.EndVertex.Displacement = lambda - 1;
                element.Xi = element.StretchRatio;
                stresses(end+1) = element.Stress;
                actualStretches(end+1) = element.StretchRatio;
            end
            
            plot(actualStretches, stresses);
            xlim([0.5, max(lambdas)]);
            grid on
            xlabel('stretch ratio')
            ylabel('stress')
            title(class(element))
            
            lambdaXiImage = [];
            i = 0;
            for lambda = lambdas
                i = i+1;
                
                j = 0;
                for xi = xis
                    j = j+1;
                    
                    element.EndVertex.Displacement = lambda - 1;
                    element.Xi = element.StretchRatio;
                    lambdaXiImage(i,j) = element.Stress;
                end
            end
            
            figure
            imagesc(lambdas, xis, lambdaXiImage)
            colorbar
            xlim([0.5, max(lambdas)]);
            grid on
            xlabel('stretch ratio')
            ylabel('xi')
            title(class(element))
       end
    end
end
