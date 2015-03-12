classdef Thread < handle
    %THREADs model a length of DE with a set of electrodes.
    
    properties   
        %Thread Properties
        StretchedLength=300e-3;     %Total thread length (m)
        PreStretch=2;               %As a stretch ratio
        
        %was res
        Resolution = 50e-3;         %Resolution: natural length of a block * preStretch (m)

        MaterialProperties = Material_Properties.Default;
        
        %The rc circuit used for each electrode
        RCCircuit = RCCircuit.Default;
        
        %Local sensing rules for each electrode
        SwitchingModelLocal  = StepModel(0,1); 
        SwitchingModelExternal = ExternalAlwaysOffModel(); 
        SwitchAllOff = 999999999999;
        
        Vertices = Vertex.empty;
        Electrodes = Electrode.empty;
        
        %NOTE: Only need to adjust ElementConstructor to choose the element subclass
        %DissertationElement used here as a stub since matlab does not
        %allow empty abstrat classes.
        ElementConstructor = @FiberConstrainedElement;
        Elements = DissertationElement.empty;
        %ElectrodedElements = DissertationElement.empty;
        
        GentParams;
    end
    
    methods
        %TODO: ensure properties are nonzero, not an empty constructor
        %Initilises to a prestretched thread at rest
        function this = Thread(stretchedLength, resolution, preStretch, elementConstructor, gentParams)
            
            this.StretchedLength = stretchedLength;
            this.PreStretch = preStretch;
            this.Resolution = resolution;
            this.ElementConstructor = elementConstructor;
            this.GentParams = gentParams;
            
            if(~Utils.IsApproxMultipleOf(this.Resolution, this.StretchedLength))
                error('stretched length is not divisible by resolution: \nstretched length %d, \nresolution: %d', this.StretchedLength, this.Resolution); 
            end
            
            %Initialise the vertices and elements to the prestretch
            %configuration
            naturalLength = this.Resolution / this.PreStretch;
            
            
            
            nElements = round(this.StretchedLength / this.Resolution);
            this.Vertices(1) = Vertex(0, 0, 0);
            
            for i = 1:nElements
                origin = this.Vertices(i).Origin + this.Resolution;
                this.Vertices(i+1) = Vertex(origin, 0, 0);
                
                initElementParams = ElementInitParams(this.Vertices(i), ...
                    this.Vertices(i+1), ...
                    preStretch, ...
                    naturalLength, ...
                    this.MaterialProperties, ...
                    this.GentParams);
                
                this.Elements(i) = this.ElementConstructor(initElementParams);
            end
        end
        
        function elements = ElectrodedElements(this)
            elements=[];
            for electrode = this.Electrodes
                elements = [elements, electrode.Elements];
            end
        end
        
        function mass = TotalMass(this)
            mass = sum(arrayfun(@(x) x.Mass, this.Elements));
        end
        
        %TODO: refactor into element
        function l = NaturalLength(this)
            l = sum(arrayfun(@(x) x.NaturalLength, this.Elements)) ;
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
            xlabel('Distance (m)')
            set(gca, 'YTick', []);
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
            
            if ~isempty(this.Electrodes) && this.Electrodes(1).RCCircuit~=this.RCCircuit
                error('the thread RCCircuit has changed, do not do this');
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

            %add the electrode
            newElectrode = Electrode(elements, type, this.RCCircuit, this.SwitchingModelLocal, this.SwitchingModelExternal);
            newElectrode.NextElectrode = nextElectrode;
            newElectrode.PreviousElectrode = previousElectrode;
            %this.ElectrodedElements = [this.ElectrodedElements, newElectrode.Elements];
            this.Electrodes(end+1) = newElectrode;
            this.DefineElectrodeNeighbours;
        end
        
        %returns the first electrode which contains the vertex
        function electrodeAtVertex = GetElectrodeAtVertex(this, vertex)
            electrodeAtVertex = [];
            for electrode = this.Electrodes
                for v = electrode.Vertices
                    if v == vertex
                        electrodeAtVertex = electrode;
                        break;
                    end
                end
                
                if(~isempty(electrodeAtVertex))
                    break;
                end
            end
        end
       
        %returns the electrode at the start vertex, if there is one
        function electrode = StartElectrode(this)
            electrode = this.GetElectrodeAtVertex(this.StartVertex);
        end
        
        function startVertex = StartVertex(this)
            startVertex = Utils.MinByKey(this.Vertices, @(x) x.Origin);
        end
        
        function endVertex = EndVertex(this)
            endVertex = Utils.MinByKey(this.Vertices, @(x) -x.Origin);
        end
        
        function element = StartElement(this)
            element = this.StartVertex.RightElement;
        end
        
        function element = EndElement(this)
            element = this.EndVertex.LeftElement;
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
            if(time >= this.SwitchAllOff)
                for electrode = this.Electrodes
                    electrode.GlobalState = false;
                end
            else
                arrayfun(@(x) x.UpdateGlobalState(time), this.Electrodes);
            end
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
        
        function SetAllElectrodeTypes(this, electrodeTypeEnum)
        
            for electrode = this.Electrodes
                electrode.Type = electrodeTypeEnum;
            end
            
        end
       
        function DefineElectrodeNeighbours(this)
            if(isempty(this.Electrodes))
                return;
            end
            
            if(length(this.Electrodes)==1)
                return;
            end
            
            orderedElectrodes = Utils.SortByKey(this.Electrodes, @(x) x.StartVertex.Origin);
            
            orderedElectrodes(1).PreviousElectrode = [];
            orderedElectrodes(1).NextElectrode = orderedElectrodes(2);
            
            for i=2:length(orderedElectrodes)-1
                orderedElectrodes(i).PreviousElectrode = orderedElectrodes(i-1);
                orderedElectrodes(i).NextElectrode = orderedElectrodes(i+1);
            end
            
            orderedElectrodes(end).PreviousElectrode = orderedElectrodes(end-1);
            orderedElectrodes(end).NextElectrode = [];
        end
        
        function [activeStretch, passiveStretch] = CalculateSteadyStateStretches(this, nCellsActive)
            
            
            
            elementInitParams = ElementInitParams(...
                    Vertex(0, 0, 0), ...
                    Vertex(this.StartElement.NaturalLength*this.PreStretch, 0, 0), ...
                    this.PreStretch, ...
                    this.StartElement.NaturalLength, ...
                    this.MaterialProperties, ...
                    this.GentParams);
            elementActive = this.ElementConstructor(elementInitParams);
            elementActive.Voltage = this.RCCircuit.SourceVoltage;
            
            elementInitParams = ElementInitParams(...
                    Vertex(0, 0, 0), ...
                    Vertex(this.StartElement.NaturalLength*this.PreStretch, 0, 0), ...
                    this.PreStretch, ...
                    this.StartElement.NaturalLength, ...
                    this.MaterialProperties, ...
                    this.GentParams);
            elementPassive = this.ElementConstructor(elementInitParams);
         
            nActiveBlocks = round(this.BlocksPerCell)*nCellsActive;            
            
            guesses = linspace(3,6,100);
            vals = arrayfun(@(x)this.CalculateSteadyStateStretchesEqn(x, nActiveBlocks, elementActive, elementPassive), guesses);
            
            close all
            plot(guesses, vals);
            grid on
            
            initialGuess = 5;
            activeStretch = fzero(@(x) this.CalculateSteadyStateStretchesEqn(x, nActiveBlocks, elementActive, elementPassive), initialGuess);
            passiveStretch = SteadyStatePassiveStretch(this, activeStretch, nActiveBlocks);
        end
        
        function blocksPerCell = BlocksPerCell(this)
            blocksPerCell = length(this.ElectrodedElements) / length(this.Electrodes);
        end
        
        function elements = GetPassiveSection(this, element)
            elements=element;
            
            while(~isempty(element) && isempty(element.RCCircuit))
                elements(end+1) = element;
                element = element.NextElement;
            end
        end
        
        function x = CalculateSteadyStateStretchesEqn(this, activeStretch, nActiveBlocks, elementActive, elementPassive)
            elementActive.SetStretchRatioAndXi(activeStretch);
            passiveStretch = this.SteadyStatePassiveStretch(activeStretch, nActiveBlocks);
            elementPassive.SetStretchRatioAndXi(passiveStretch);
            
            x = elementActive.Force - elementPassive.Force;
        end
        
        %assuming the material is split into two sections of equal stetch
        function passiveStretch = SteadyStatePassiveStretch(this, activeStretch, nActiveBlocks)
            %a = length(this.ElectrodedElements); %num active blocks
            if(nActiveBlocks < 0)
                error('input must be integer');
            end
            
            a = nActiveBlocks;
            p = length(this.Elements) - a; %num passive blocks
            L = this.StartElement.NaturalLength; %
            l = this.StretchedLength;
            
            passiveStretch = (l - (a*L*activeStretch))/ ...
                                      (p*L);
        end
        
        function voltage = DrivingVoltageForStretch(this, activeStretch)
            passiveStretch = this.SteadyStatePassiveStretch(activeStretch, length(this.ElectrodedElements));
           
            elementInitParams = ElementInitParams(...
                    Vertex(0, 0, 0), ...
                    Vertex(this.StartElement.NaturalLength*activeStretch, 0, 0), ...
                    this.PreStretch, ...
                    this.StartElement.NaturalLength, ...
                    this.MaterialProperties, ...
                    this.GentParams);
            elementActive = this.ElementConstructor(elementInitParams);
            
            elementInitParams = ElementInitParams(...
                    Vertex(0, 0, 0), ...
                    Vertex(this.StartElement.NaturalLength*passiveStretch, 0, 0), ...
                    this.PreStretch, ...
                    this.StartElement.NaturalLength, ...
                    this.MaterialProperties, ...
                    this.GentParams);
            elementPassive = this.ElementConstructor(elementInitParams);
             
            %active stress
            elementActive.SetStretchRatio(activeStretch);
            elementActive.Xi = activeStretch;
            
            %passive stress
            elementPassive.SetStretchRatio(passiveStretch);
            elementPassive.Xi = passiveStretch;
            
            initialGuess = 5000;
            voltage = fzero(@(x)this.EquilibriumEquation(elementActive, elementPassive, x), initialGuess);
        end
        
        %as derived in the paper
        %TODO: Cleanup the bodgy stress calculations
        function sourceVoltage = CalculateDrivingVoltage(this)  
            %TODO: not hardcoded, maybe
            %These hardcoded parameters discretise nicely :)
            lambdaA = 5;
            lambdaB = 1.25;
            
            elementInitParams = ElementInitParams(...
                    Vertex(0, 0, 0), ...
                    Vertex(this.StartElement.NaturalLength*this.PreStretch, 0, 0), ...
                    this.PreStretch, ...
                    this.StartElement.NaturalLength, ...
                    this.MaterialProperties, ...
                    this.GentParams);
            elementActive = this.ElementConstructor(elementInitParams);
            
            elementInitParams = ElementInitParams(...
                    Vertex(0, 0, 0), ...
                    Vertex(this.StartElement.NaturalLength*this.PreStretch, 0, 0), ...
                    this.PreStretch, ...
                    this.StartElement.NaturalLength, ...
                    this.MaterialProperties, ...
                    this.GentParams);
            elementPassive = this.ElementConstructor(elementInitParams);
            
            elementActive.SetStretchRatioAndXi(lambdaA);
            elementPassive.SetStretchRatioAndXi(lambdaB);
            
            
%             guesses=[];
%             voltages = linspace(3000, 6000, 1000);
%             for voltage = voltages
%                 guesses(end+1) = this.EquilibriumEquation(elementActive, elementPassive, voltage);
%             end
%             
%             close all; grid on
%             plot(voltages, guesses);grid on;
%             
            initialGuess = 5000;
            sourceVoltage = fzero(@(voltage) this.EquilibriumEquation(elementActive, elementPassive, voltage), initialGuess);
        end
       
        function SetAtSteadyState(this, globalState)
            
        
        end
        
        
        %The root of this equation 
        function x = EquilibriumEquation(this, elementActive, elementPassive, voltage)
             elementActive.Voltage = voltage;
            
             activeStress = elementActive.MaterialStress;
             electricalStress = elementActive.ElectricalStress;
             activeFaceArea = elementActive.LengthFaceArea;
             
             passiveFaceArea = elementPassive.LengthFaceArea;
             passiveStress = elementPassive.MaterialStress;
             
             x =  (electricalStress - activeStress)*activeFaceArea + passiveStress*passiveFaceArea;
        end
        
        
    end
    
    methods(Static)
        %initialises a thread with equally spaced, locally controlled electrodes
        %The start electrode is an externally controlled cell
        %uses the default rc circuit for the element
        function this = ConstructThreadWithSpacedElectrodes( ...
                preStretch, ...
                cellLengthAtPrestretch, ...
                nCells, ...
                spacingAtPreStretch, ...
                switchingModelLocal, ...
                switchingModelExternal, ...
                gentParams, ...
                varargin) %optionally the elment type
        
            if(nargin == 8)
                elementConstructor = varargin{1};
            else
                elementConstructor = @FiberConstrainedElement;
            end
            
            pauseTime = 2;
            
            %Two coarsest resolution is the greatest common divisor of
            %cellLength and spacing
            gcdAccuracy = 10^2 * 10^(-Utils.Order(Utils.Tolerance)); %Two orders above tolerance should do it!
            resolution = gcd(floor(gcdAccuracy*cellLengthAtPrestretch), floor(gcdAccuracy*spacingAtPreStretch)) / gcdAccuracy;
            
            stretchedLength = cellLengthAtPrestretch*nCells + (nCells-1) * spacingAtPreStretch;
            this = Thread(stretchedLength, resolution, preStretch, elementConstructor, gentParams);
            
            this.SwitchingModelLocal = switchingModelLocal;
            this.SwitchingModelExternal = switchingModelExternal;
            
            %Default RC circuit used here
            this.RCCircuit = this.StartElement.DefaultRCCircuit;
            this.RCCircuit.SourceVoltage = this.CalculateDrivingVoltage;
            
            clc; 
            sigFigs = 2;
            %TODO: DRY the string formatting
            fprintf('Coarsest Resolution: %.2e\n', Utils.RoundSigFigs(resolution, sigFigs));
            fprintf('Source Voltage: %.2e\n', Utils.RoundSigFigs(this.RCCircuit.SourceVoltage, sigFigs));
            fprintf('Resistance: %.2e\n', Utils.RoundSigFigs(this.RCCircuit.Resistance, sigFigs));
            
            electrodeType = ElectrodeTypeEnum.LocallyControlled;
            this.FillWithElectrodes(this.StartVertex.Origin, cellLengthAtPrestretch, electrodeType, spacingAtPreStretch);
            this.StartElectrode.Type = ElectrodeTypeEnum.ExternallyControlled;
        end
        
        
    end
end
