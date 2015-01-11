classdef Thread < handle
    %THREAD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties   
        %Thread Properties
        StretchedLength=300e-3;     %Total thread length (m)
        PreStretch=2;               %As a stretch ratio
        
        %was res
        Resolution = 50e-3;         %Resolution: natural length of a block * preStretch (m)

        %TODO: Natural width
        MaterialProperties = Material_Properties.Default;
        
        %Should be a- constructor of Material_model
        %TODO: Add a check for this
        %TODO: Add a default gent model
        InternalStressModel = Gent_Model();
        
        %The rc circuit used for each electrode
        RCCircuit = RCCircuit.Default;
        
        %Local sensing rules for each electrode
        SwitchingModelLocal  = StepModel(0,0); 
        SwitchingModelExternal = ExternalAlwaysOffModel(); 
        
        %%TODO: Pair element with model in a tidier way
        %by default a rested element (lambda=xi)
        %ElementConstructor = @(x)Element(x,x,this.InternalStressModel);
        
        Vertices = Vertex.empty;
        Electrodes = Electrode.empty;
        
        %DissertationElement used here as a stub since matlab does not
        %allow empty abstrat classes. Any class that inherits from Element
        %can live in these arrays
        Elements = DissertationElement.empty;
        ElectrodedElements = DissertationElement.empty;
    end
    
    methods
        %TODO: ensure properties are nonzero, not an empty constructor
        %Initilises to a prestretched thread at rest
        function this = Thread(stretchedLength, resolution, preStretch, rcCircuit)
            this.StretchedLength = stretchedLength;
            this.PreStretch = preStretch;
            this.Resolution = resolution;
            this.RCCircuit = rcCircuit;  
            
            if(~Utils.IsApproxMultipleOf(this.Resolution, this.StretchedLength))
                error('stretched length is not divisible by resolution: \nstretched length %d, \nresolution: %d', this.StretchedLength, this.Resolution); 
            end
            
            %Initialise the vertices and elements to the prestretch
            %configuration
            naturalLength = this.Resolution / this.PreStretch;
            
            %TODO: Refactor this when other models are considered
            naturalWidth = naturalLength;
            
            %TODO: This should probably come from materia
            
            nElements = round(this.StretchedLength / this.Resolution);
            this.Vertices(1) = Vertex(0, 0, 0);
            
            for i = 1:nElements
                origin = this.Vertices(i).Origin + this.Resolution;
                this.Vertices(i+1) = Vertex(origin, 0, 0);
                
                %Only need to edit this line to change the element type
                this.Elements(i) = DissertationElement(this.Vertices(i), ...
                    this.Vertices(i+1), ...
                    preStretch, ...
                    naturalLength, ...
                    naturalWidth, ...
                    this.InternalStressModel, ...
                    this.MaterialProperties);
            end
        end
        
        %TODO: refactor when including different dimensions
        function mass = TotalMass(this)
            mass = this.NaturalLength^2 * this.NaturalThickness * this.MaterialProperties.Density;
        end
        
        %TODO: refactor into element
        function l = NaturalLength(this)
            l = this.Resolution / this.PreStretch;
        end
        
        %plot the thread
        %optional bool arg to plot vertices (default: true)
        function Plot(this, varargin)
            if(nargin == 2)
                plotDots = varargin{1};
            else
                plotDots = true;
            end
            
            hold on
            linewidth=10;
            
            %Plot the thing
            plot(0,0,'w','linewidth', linewidth);
            plot(0,0,'k','linewidth', linewidth);
            plot(0,0,'r','linewidth', linewidth);
            plot(0,0,'g','linewidth', linewidth);
            legend('Membrane', 'Local Sensing Electrode', 'External Sensing Electrode', 'Undefined Electrode') 
            
            %Plot the Electrodes
            y = [0,0];
            for electrode = this.Electrodes
                %Determine the color
                switch electrode.Type
                    case ElectrodeTypeEnum.LocallyControlled
                        color = 'k';
                    case ElectrodeTypeEnum.ExternallyControlled
                        color = 'r';
                    case ElectrodeTypeEnum.Undefined
                        color = 'g';
                end
                
                plot([electrode.StartVertex.Position, electrode.EndVertex.Position], y, color, 'linewidth', linewidth);
            end

            if plotDots~=0
                %Plot the Nodes
                y=zeros(length(this.Vertices),1);
                x=0 : this.Resolution : this.StretchedLength;
                scatter(x,y,100,'filled');
            end

            xlim([0, this.StretchedLength])
        end
            
        %TODO: Plot onto a cuttlefish
        
        function vertexAtPosition = GetVertexAtPosition(this, position)
            vertexAtPosition=[];
            for vertex = this.Vertices
                
                if Utils.WithinTolerance(vertex.Position, position)
                    vertexAtPosition = vertex;
                    break
                end
                
            end
        end
        
        %Add an Electode:
        %start: the position (m) to begin the electrode
        %elecLen: the length of the electrode(m).
        %These dimensions should match the discretisation
        function AddElectrode(this, start, electrodeLength, type)
            
            %Find which vertex matches the start point
            startVertex = this.GetVertexAtPosition(start);            
            if(isempty(startVertex))
                error(strcat(['Start position must lie on a vertex,', ...
                    'which usually start off occuring at', ...
                    'multiple of the resolution: %d']), this.resolution);
            end                
            
            %Find the end vertex
            endVertex = this.GetVertexAtPosition(start+electrodeLength);
            if(isempty(endVertex))
                error(strcat(['end point of electrode must lie on a vertex', ... 
                    'on an intially constructed thread these lie ',...
                    'at multiples of the resolution: %d']), this.resolution);
            end     
            
            if(startVertex == endVertex)
                error('give the electrode some length!');
            end
            
            %Check that introducing this electrode would not cause an
            %overlap
            for electrode = this.Electrodes
                if (electrode.EndVertex.Position > startVertex.Position) && ...
                   (endVertex.Position > electrode.StartVertex.Position)
               
                    error('cannot introduce an electrode that would cause an overlap')
                end
            end
            
            
            %Set previousElectrode. Find electrode with a startVertex
            %closest to the startVertex but less than it
            previousElectrode = [];
            bestProximity = -Inf;
            for electrode = this.Electrodes
                electrodeProximity = startVertex.Position - electrode.StartVertex.Position; 
                
                if electrodeProximity < 0 && electrodeProximity > bestProximity
                    previousElectrode = electrode;
                end
            end
            
            
            %Set nextElectrode. Find electrode with a endVertex
            %closest to the previousElectrode but more than it
            nextElectrode = [];
            bestProximity = Inf;
            for electrode = this.Electrodes
                electrodeProximity = startVertex.Position - electrode.StartVertex.Position; 
                
                if electrodeProximity > 0 && electrodeProximity < bestProximity
                    nextElectrode = electrode;
                end
            end
            
            %Gather all elements between start/end vertex
            currentVertex = startVertex;
            elements = DissertationElement.empty;
            while (currentVertex ~= endVertex)
                elements(end+1) = currentVertex.RightElement;
                currentVertex = currentVertex.Next;
            end
            
            %assign the switching model
            switchingModel = [];
            switch type
                case ElectrodeTypeEnum.ExternallyControlled
                    switchingModel = this.SwitchingModelExternal;
                    
                case ElectrodeTypeEnum.LocallyControlled
                    switchingModel = this.SwitchingModelLocal;
                    
                case ElectrodeTypeEnum.Undefined
                    switchingModel = [];
            end
            
            %add the electrode
            newElectrode = Electrode(elements, type, this.RCCircuit, switchingModel);
            newElectrode.NextElectrode = nextElectrode;
            newElectrode.PreviousElectrode = previousElectrode;
            this.ElectrodedElements = [this.ElectrodedElements, newElectrode.Elements];
            this.Electrodes(end+1) = newElectrode;
        end
        
        %Paints electrodes with equal length and spacing from the start
        %point until the end of thread (or it meets another electrode)
        function FillWithElectrodes(this, start, electrodeLength, electrodeType, spacing)
            if(isempty(this.GetVertexAtPosition(start)))
                error('Start point does not align with a vertex!')
            end
            
            if(~Utils.IsApproxMultipleOf(this.Resolution, electrodeLength))
                error('electrode length must be a multiple of the resolution!')
            end
            
            if(~Utils.IsApproxMultipleOf(this.Resolution, spacing))
                error('electrode length must be a multiple of the resolution!')
            end
            
            while(true)
                try
                    this.AddElectrode(start, electrodeLength, electrodeType);
                    start = start + electrodeLength + spacing;
                catch
                    break;
                end
            end
        end
        
        %For use with an ode solver: state variables of the system
        %vars are [disaplcement, velocity, xi, voltage]
        function state = GetLocalState(this)
            state=[];
            state = [state, arrayfun(@(x) x.Displacement, this.Vertices)];
            state = [state, arrayfun(@(x) x.Velocity, this.Vertices)];
            state = [state, arrayfun(@(x) x.Xi, this.Elements)];
            state = [state, arrayfun(@(x) x.Voltage, this.ElectrodedElements)];
        end
        
        %For use with an ode solver
        %vars are [disaplcement, velocity, xi, voltage]
        function SetLocalState(this, state)
            index = 1;
            displacements = state(index : index+length(this.Vertices)-1);
            index = index + length(this.Vertices);
            
            velocities = state(index : index+length(this.Vertices)-1);
            index = index + length(this.Vertices);
            
            xis = state(index : index+length(this.Elements)-1);
            index = index + length(this.Elements);
            
            voltages = state(index : index+length(this.ElectrodedElements)-1);
            index = index + length(this.ElectrodedElements);
            
            
            for i=1:length(this.Vertices)
                this.Vertices(i).Displacement = displacements(i);
                this.Vertices(i).Velocity = velocities(i);
            end
            
            for i=1:length(this.Elements)
                this.Elements(i).Xi = xis(i);
            end
            
            count = 0;
            for electrode = this.Electrodes
                for i=1:length(electrode.Elements)
                    count = count+1;
                    electrode.Elements(i).Voltage = voltages(count);
                end
            end
        end
        
        function UpdateGlobalStates(this, time)
            arrayfun(@(x) x.UpdateGlobalState(time), this.Electrodes);
        end

        function SetGlobalState(this, state)
            if(length(state)~=length(this.Electrodes))
                error('number of state vars does not match number of electrodes: %i (expecting %i)', length(state), length(this.Electrodes));
            end
            
            for i=1:length(this.Electrodes)
                this.Electrodes(i).GlobalState = state(i);
            end
        end
        
        %output should be d/dt[disaplcement, velocity, xi, voltage]
        function state = GetRateLocalState(this)
            state = [];
            state = [state, arrayfun(@(x) x.Velocity, this.Vertices)];
            state = [state, arrayfun(@(x) x.Acceleration, this.Vertices)];
            state = [state, arrayfun(@(x) x.DXi, this.Elements)];
            state = [state, arrayfun(@(x) x.DVoltage, this.Electrodes)];
        end
        
        function state = GetGlobalState(this)
            state = arrayfun(@(x) x.GlobalState, this.Electrodes);
        end
    end
end
