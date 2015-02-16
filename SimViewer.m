classdef SimViewer < handle
    properties
        Sim;
        States;
        RawData;
        
        %In seconds, how often to take a line of data
        Resolution = 1;
        
        ReportsFolder = '../reports/';
        SaveToFolder = strcat([this.ReportsFolder, this.Sim.Name, '/']);
            
    end
    
    methods
        %Pass in the name of sim, not the path
        function this = SimViewer(name, varargin)
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
        
        %TODO: Dont think this actually works
        function AnimateSim(this)
            close all;
            
            for state = this.States
                state.SetState;
                clf
                state.Thread.Plot
                title(sprintf('%.2f(s)', state.Time));
                pause(0.3);
            end
        end
        
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
            
            title('Sim Material')
            xlabel('Time (s)');
            ylabel('Distance (m)');
        end
        
        function PlotGlobal(this)
            
            %%%%Plotting Colours
            c1 = [1,1,1]; %Cell is on
            c2 = [0,0,0]; %Cell is off
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
            x=0;y=0; ms=15;
            plot(x,y,'marker','square','markersize',ms,...
                'markeredgecolor','k','markerfacecolor',c1,...
                'color','w');
            plot(x,y,'marker','square','markersize',ms,...
                'markeredgecolor','k','markerfacecolor',c2,...
                'color','w');
            % plot(x,y,'color',c1,'linewidth',lw)
            legend('G(i) = 0', 'G(i) = 1');
            % set(legHandle,'color',legColor)
            % set(legHandle,'FontWeight','bold')
           
            %Plot the image
            times = this.Times;
            nElectrodes = length(this.Sim.Thread.Electrodes);
            imagesc(times, 1:nElectrodes, globalStates');
            colormap(flipud(gray));
            
            xlim([min(times), max(times)]);
            set(gca, 'YTick', 1:nElectrodes);
            %ylim([1, nElectrodes]);
            
            %And the gridlines
            yGridPositions = 0.5:1:nElectrodes+0.5;
            for position = yGridPositions
                x=[times(1), times(end)];
                y=[position, position];
                plot(x,y,'color',gridColor)
            end
            
            title('Global State');
            xlabel('Time (s)');
            ylabel('Electrode');
        end
        
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
        
        %plot by key upon the list
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
        
        function LoadCSV(this)
            
            id = fopen(this.Sim.CSVFilename(this.Sim.Name), 'r');
            
            %Read a line
            line = this.TakeLine(id);
            
            %Get the data
            this.RawData=[];
            
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
                        this.RawData = [this.RawData; line];
                        
                        this.SaveState(line);
                        %Reset sum
                        takeLineSum=0;
                    end
                    
                    %Print every 100
                    if countPeriod==100
                        clc; fprintf('Time Loaded: %.0fs\n',line(1))
                        countPeriod=0;
                    end
                    
                    %Break if necessary
                    %                     if rangeSpecified && (line(1)~=-1) && (tRange(2) <= tLineNum(1))
                    %                         break
                    %                     end
                end
            end
            
            %Close the file
            fclose('all');
            
        end
        
        
        %Format: [t, local, global]
        function SaveState(this, line)
            
            nLocalVars = length(this.Sim.Thread.GetLocalState);
            nGlobalVars = length(this.Sim.Thread.GetGlobalState);
            
            total = 1 + nLocalVars + nGlobalVars;
            
            %check if line has the correct number of elements
            width = size(this.RawData,2);
            if width ~= total
                error(strcat(['incorrect number of elements: ', total, ...
                    ' (expecting: ', width]));
            end
            
            %split the line
            t = line(1);
            index = 2;
            
            localState = line(index : index + nLocalVars - 1);
            index = index + nLocalVars;
            
            globalState = line(index : index + nGlobalVars - 1);
            
            this.States = [this.States, ThreadState(this.Sim.Thread, t, localState, globalState)];
        end
        
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
        
        function GenReport(this)
            this.SaveFigure(@this.PlotMaterial, 'material')
            this.SaveFigure(@this.PlotGlobal, 'global_states')
            this.SaveFigure(@this.PlotStretchRatio, 'stretch_ratio')
            this.SaveFigure(@this.PlotVoltage, 'voltage')
            this.SaveFigure(@this.PlotSource, 'source')
           
            save(strcat([this.SaveToFolder, this.Sim.Name, '.mat']), 'this');
        end
        
        %f() is expected to yield a figure
        function SaveFigure(this, f, name)
            close all
            figure
            f();
            format = 'png';
            
            if(~exist(saveToFolder, 'dir'))
                mkdir(saveToFolder);
            end
            
            reportPath = strcat([this.SaveToFolder, name, '.', format]);
            saveas(gcf, reportPath, format);
        end
    end
    
end