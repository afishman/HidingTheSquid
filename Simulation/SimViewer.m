classdef SimViewer < handle
    %Used to view and analyse simulation data.
    %GenReport can be used to export sim data and common analysis images to
    %a folder
    properties
        Sim;
        States;
        RawData;
        Name;
        
        %In seconds, how often to take a line of data. Use coarser
        %resolution if the simulation is large and you don't have the
        %memory for it.
        Resolution = 0.01;
        
        ReportsFolder;
    end
    
    methods (Static)
        %TODO: Delete this when I make sense of it!
        function viewer = LoadReport(name)
            %TODO: DRY this up into a utility
            path = strcat([DefaultSettings.ReportsFolder, name, '/',name]);
            viewer = SimViewer(path);
        end
        
        function viewer = QuickView(name)
            viewer = SimViewer(name);
            close all;
            
            figure;
            viewer.PlotMaterial;
            
            figure;
            viewer.PlotGlobal;
            
            figure;
            viewer.PlotSource;
        end
    end
    
    methods
        %Pass in the name of sim, not the path
        function this = SimViewer(name, varargin)
            this.ReportsFolder = DefaultSettings.ReportsFolder;
            this.Name = name;
            this.States = [];
            
            %Filename
            %TODO: DRY this with what's in SimulateThread
            if(~exist(SimulateThread.SimObjectFilename(name), 'file'))
                error(strcat([SimulateThread.SimObjectFilename(name), ' file does not exist']));
            end
            
            simStruct = load(SimulateThread.SimObjectFilename(name), SimulateThread.ObjectName);
            eval(strcat(['this.Sim = simStruct.', SimulateThread.ObjectName]));
            
            if(~exist(SimulateThread.CSVFilename(name), 'file'))
                error(strcat([SimulateThread.CSVFilename(name), ' does not exist']));
            end
            
            if nargin == 2
                this.Resolution = varargin{1};
            end
            
            this.LoadCSV;
        end
        
        function name = OutputFolder(this)
            name = strcat([this.ReportsFolder, this.Sim.Name, '/']);
            
            if(~exist(name, 'dir'))
                mkdir(name);
            end
        end
        
        %plots the length material against time
        function PlotMaterial(this)
            rightElementPositionMatrix = [];
            leftElementPositionMatrix = [];
            
            electrodeColor = 'k';
            membraneColor = 'w';
            
            time = this.Times;
            
            for state = this.States
                state.SetState;
                
                elements = Utils.SortByKey(state.Thread.ElectrodedElements, @(x) -x.EndVertex.Position);
                
                rightElementPositionMatrix = [rightElementPositionMatrix; ...
                    arrayfun(@(x) x.EndVertex.Position, elements)];
                
                leftElementPositionMatrix = [leftElementPositionMatrix; ...
                    arrayfun(@(x) x.StartVertex.Position, elements)];
            end
            
            xlim([min(time), max(time)]);
            
            ylim([0, this.States(1).Thread.StretchedLength]);
            
            hold on
            for i=1:size(rightElementPositionMatrix,2)
                h = area(time, rightElementPositionMatrix(:,i));
                set(h, 'FaceColor', electrodeColor);
                
                h = area(time, leftElementPositionMatrix(:,i));
                set(h, 'FaceColor', membraneColor);
            end
            
            %title('Sim Material')
            xlabel('Time (s)');
            ylabel('Distance (m)');
        end
        
        %plots the global state against time
        function PlotGlobal(this)
            %Plotting Colours
            %Cell is on
            c1 = [1,1,1];
            
            %Cell is off
            c2 = [0,0,0];
            
            gridColor = [0.3, 0.3, 0.3];
            
            %form the image: x is electrode, y is time
            hold on
            electrodes = Utils.SortByKey(this.Sim.Thread.Electrodes, @(x) x.EndVertex.Position);
            globalStates = [];
            for state = this.States
                state.SetState;
                globalStates = [globalStates; arrayfun(@(x) x.GlobalState, electrodes)];
            end
            
            %Make the legend
            x=0;y=-1; ms=15;
            plot(x,y,'marker','square','markersize',ms,...
                'markeredgecolor','k','markerfacecolor',c1,...
                'color','w');
            plot(x,y,'marker','square','markersize',ms,...
                'markeredgecolor','k','markerfacecolor',c2,...
                'color','w');
            
            leg = legend('G(i) = 0', 'G(i) = 1', 'Location','northwest');
            legSize = get(leg, 'FontSize');
            set(leg, 'FontSize', legSize*JournalFigure.LegendTextAdjustment);
            
            %Plot the image
            times = this.Times;
            nElectrodes = length(this.Sim.Thread.Electrodes);
            
            %HACK: oh matlab! The hacky things you make me do to get production
            %quality images! (Using imagesc produces blurry eps images)
            pcolor(times, 0:nElectrodes, [globalStates, zeros(size(globalStates,1),1)]');
            
            shading flat
            
            colormap(flipud(gray));
            
            xlim([min(times), max(times)]);
            
            set(gca, 'YTick', 0.5:1:nElectrodes-0.5);
            set(gca, 'YTickLabel', 1:nElectrodes);
            ylim([0, nElectrodes]);
            
            %And the gridlines
            yGridPositions = 0:1:nElectrodes;
            for position = yGridPositions
                x=[times(1), times(end)];
                y=[position, position];
                plot(x,y,'color',gridColor)
            end
            
            %title('Global State');
            xlabel('Time (s)');
            ylabel('Electrode');
        end
        
        %The time at each state
        function time = Times(this)
            time = arrayfun(@(x) x.Time, this.States);
        end
        
        function PlotVoltage(this)
            this.PlotByKey(@(x) x.Voltage, this.Sim.Thread.Elements);
            ylabel('Voltage (V)');
            title('Voltage');
        end
        
        function PlotStress(this)
            this.PlotByKey(@(x) x.Stress, this.Sim.Thread.Elements);
            ylabel('Stress (pa)');
            title('Stress');
        end
        
        function PlotXi(this)
            this.PlotByKey(@(x) x.Xi, this.Sim.Thread.Elements);
            ylabel('Xi (pa)');
            title('Xi');
        end
        
        function PlotNodeForces(this)
            this.PlotByKey(@(x) x.Force, this.Sim.Thread.Vertices);
            ylabel('Forces (N)');
            title('Node Forces');
        end
        
        function PlotDVoltage(this)
            this.PlotByKey(@(x) x.DVoltage, this.Sim.Thread.Electrodes);
            ylabel('Voltage (V)');
            title('D-Voltage');
        end
        
        function PlotStretchRatio(this)
            this.PlotByKey(@(x) x.StretchRatio, this.Sim.Thread.Elements);
            ylabel('Stretch Ratio');
            title('Stretch Ratio');
        end
        
        function PlotSource(this)
            this.PlotByKey(@(x) x.Source, this.Sim.Thread.Electrodes);
            ylabel('Source');
            title('Source');
        end
        
        function PlotEventsFunValue(this)
            this.PlotByKey(@(x) x.Source, this.Sim.Thread.Electrodes);
            ylabel('Source');
            title('Source');
        end
        
        %plot by key against list. Provides an easy way to plot various
        %properties
        function PlotByKey(this, key, list)
            time = this.Times;
            
            theArray = [];
            for state = this.States
                state.SetState;
                theArray = [theArray; arrayfun(key, list)];
            end
            
            plot(time, theArray);
            xlabel('Time (s)')
            ylabel('the thing');
            grid on
        end
        
        %Load data from the CSV
        function LoadCSV(this)
            id = fopen(this.Sim.CSVFilename(this.Name), 'r');
            
            try
                %Read a line
                this.RawData=[];
                line = this.TakeLine(id);
                this.AddToRawData(line);
                
                %The rate: pps
                %Initialise for the while loop
                count=0;
                countPeriod=0;
                prevTime=0;
                takeLineSum=0;
                while line~=-1
                    %Increase line count
                    count=count+1;
                    countPeriod=countPeriod+1;
                    
                    %Get the next line
                    line = this.TakeLine(id);
                    
                    %If we're not at the end
                    if line~=-1
                        %Add to tSum
                        dT = line(1) - prevTime;
                        takeLineSum = takeLineSum + dT;
                        prevTime = line(1);
                        
                        %Get the data, take everything below t=0
                        %TODO: This is silly, there should be a time indepndant
                        %solution here
                        if (line~=-1) & ((takeLineSum>this.Resolution) | line(1)<=0)
                            this.AddToRawData(line);
                            %Reset sum
                            takeLineSum=0;
                        end
                        
                        %Print every 100
                        if countPeriod==100
                            clc; fprintf('Time Loaded: %.0fs\n',line(1))
                            countPeriod=0;
                        end
                    end
                end
                
                this.SetStatesToRawData();
                
                %Close the file
                fclose(id);
            catch ex
                %Close the file
                fclose(id);
                rethrow(ex)
            end
        end
        
        function AddToRawData(this, line)
            this.RawData = [this.RawData; line];
        end
        
        function SetStatesToRawData(this)
            times = this.RawData(:,1);
            sampleTimes = times(1) : this.Resolution : times(end);
            this.States = this.InterpolateRawData(sampleTimes);
        end
        
        %Interpolate raw data, returning thread states
        function states = InterpolateRawData(this, sampleTimes)
            states=ThreadState.empty;
            
            times = this.RawData(:,1);
            interpolated = interp1(times, this.RawData, sampleTimes);
            
            for i=1:size(interpolated,1)
                states(end+1) = this.MakeState(interpolated(i,:));
            end
        end
        
        function ResetRawDataAndStates(this, states)
            this.RawData=[];
            
            for state = states
                line = [state.Time, state.LocalState, state.GlobalState];
                this.RawData=[this.RawData; line];
            end
            
            this.SetStatesToRawData;
        end
        
        %Format: [t, local, global]
        function SaveState(this, line)
            this.States = [this.States, this.MakeState(line)];
        end
        
        %Create a thread state out of a line of raw data
        function state = MakeState(this, line)
            nLocalVars = length(this.Sim.Thread.GetLocalState);
            nGlobalVars = length(this.Sim.Thread.GetGlobalState);
            
            total = 1 + nLocalVars + nGlobalVars;
            
            %check if line has the correct number of elements
            width = size(this.RawData,2);
            if length(line) ~= total
                error(strcat(['incorrect number of elements: ', total, ...
                    ' (expecting: ', width]));
            end
            
            %split the line
            t = line(1);
            index = 2;
            
            localState = line(index : index + nLocalVars - 1);
            index = index + nLocalVars;
            
            %Create the state
            globalState = round(line(index : index + nGlobalVars - 1));
            state = ThreadState(this.Sim.Thread, t, localState, globalState);
        end
        
        %Returns a line of data
        function line = TakeLine(this, id)
            tline = fgetl(id);
            
            if tline == -1
                line = -1;
            else
                line = str2num(tline);
            end
        end
        
        function maxDisplacements = MaxDisplacements(this)
            displacements = [];
            
            for state = this.States
                state.SetState;
                
                displacements = [displacements; ...
                    arrayfun(@(x) x.Displacement, this.Sim.Thread.Vertices)];
                
            end
            
            maxDisplacements = max(displacements);
        end
        
        %For debug really
        function FFTOfFirstVertex(this)
            positions = [];
            for state = this.States
                state.SetState;
                
                positions(end+1) = this.Sim.Thread.StartVertex.Next.Position;
            end
            
            [freqs, amp] = Utils.FFT(this.Times, positions);
            
            freqs = freqs(2:end);
            amp = amp(2:end);
            
            plot(freqs, amp);
            xlabel('Frequency (Hz)');
            ylabel('Amplitude');
        end
        
        %Creates a report. Essentially the data for a simulation along
        %with a set of accompanying images
        function GenReport(this)
            this.SaveFigure(@this.PlotMaterial, 'material')
            this.SaveFigure(@this.PlotGlobal, 'global_states')
            this.SaveFigure(@this.PlotStretchRatio, 'stretch_ratio')
            this.SaveFigure(@this.PlotVoltage, 'voltage')
            this.SaveFigure(@this.PlotSource, 'source')
            
            %TODO: DRYing
            from = SimulateThread.SimObjectFilename(this.Sim.Name);
            to = strcat([this.OutputFolder, this.Sim.Name, '.mat']);
            copyfile(from, to);
            
            from = SimulateThread.CSVFilename(this.Sim.Name);
            to = strcat([this.OutputFolder, this.Sim.Name, '.csv']);
            copyfile(from, to);
        end
        
        %f() is expected to yield a figure
        function SaveFigure(this, f, name)
            close all
            figure
            f();
            format = 'png';
            
            reportPath = strcat([this.OutputFolder, name, '.', format]);
            saveas(gcf, reportPath, format);
        end
        
        %Extends the start of a simulation by t by copying the initial thread state.
        %ForceOff forces all the global states to be off during this
        %extension
        function ExtendStart(this, t, forceOff)
            if(nargin == 2)
                forceOff = false;
            end
            
            if(forceOff)
                globalState = false(1,length(this.States(1).GlobalState));
            else
                globalState = this.States(1).GlobalState;
            end
            
            thread = this.States(1).Thread;
            localState = this.States(1).LocalState;
            
            newState1 = ThreadState(thread, t, localState, globalState);
            newState2 = ThreadState(thread, this.States(1).Time-eps, localState, globalState);
            newStates = [newState1, newState2, this.States];
            
            this.ResetRawDataAndStates(newStates);
        end
    end
end