%This object runs simulations.
classdef SimulateThread < handle
    properties
        %%%Sim name, used for saving/loading
        Name='default';
        
        CurrentTime;
        
        Thread;     %Thread that is edited during simulation 
        
        TimeTakenToSimulate = 0;
        
        
        %%% Some General properties
        RelativeErrorTolerance = 1e-6;  %ODE relative error tolerance
        SimTime = 0;  %Time taken for the sim to process;
        PointsPerSecond    = 100;   %Points per second when saving data (using linearly interpolated points) 
       
    end
    
    methods
        function this=SimulateThread(name, thread)
            this.Name = name;
            this.Thread = thread;
        end
        
        %Runs the sim from t=0 until t=tMax, DELETING any previously
        %existing sim
        function RunSim(this, tMax)
            %Delete the old text file
            if(exist(SimulateThread.CSVFilename(this.Name), 'file'))
                delete (SimulateThread.CSVFilename(this.Name))
            end
            
            this.CurrentTime = 0;
            this.TimeTakenToSimulate = 0;
            
            %Run the sim
            this.DoSim(tMax)
        end

        %Runs the simulation from the current state of the thread until
        %t = tMax
        function DoSim(this, tMax)
            %How often to flush data to file
            tEvery = 0.5;
            
            this.Thread.UpdateGlobalStates(this.CurrentTime);
            
            %%%Main Routine
            %TODO: refactor this into json
            %Save the object
            save(SimulateThread.SimObjectFilename(this.Name), 'this');
            
            %ODE options
            options=odeset('Events', @(t,y)this.EventsFun(t,y), 'RelTol', this.RelativeErrorTolerance);
            
            %Run the ODE
            tStart=this.CurrentTime;
            while tStart<tMax
                clc;fprintf('Time: %.2fs\n', tStart)
                %Start timer
                tic;
                
                %Set the End time
                tEnd = min([tStart+tEvery, tMax]);
                
                %Run the ODE for a bit
                [t, outputVars] = ode15s(@(t,inVars)this.OdeFun(t,inVars), [tStart, tEnd], this.Thread.GetLocalState, options);
                
                %The new Starting time
                tStart=t(end);
                
                %Number of points for interpolation
                nPts = round(this.PointsPerSecond*(t(end)-t(1)) );
                nPts = max([3, nPts]); %Use at least some!
                
                %Linearly Interpolate Data
                tNew = linspace(t(1), t(end), nPts);
                outputVars = interp1(t, outputVars, tNew);
                t = tNew;
                
                %write to file - todo save global state too
                globalStates = repmat(this.Thread.GetGlobalState, size(outputVars,1), 1);
                Utils.AppendToFile([t', outputVars, globalStates], SimulateThread.CSVFilename(this.Name));
                
                %Save the object
                this.TimeTakenToSimulate = this.TimeTakenToSimulate + toc;
                eval(strcat([SimulateThread.ObjectName, '=this;']));
                save(this.SimObjectFilename(this.Name), SimulateThread.ObjectName)
                
                %The new Starting Variables
                this.Thread.SetLocalState(outputVars(end, :));
                this.Thread.UpdateGlobalStates(t(end));
                
                %TODO: is this really necessary?
                %Cleanup a bit
                clear outputVars t
            end
        end
             
        function [value,isterminal,direction] = EventsFun(this, t, y)
            this.Thread.SetLocalState(y);
            [value,isterminal,direction] = arrayfun(@(x) x.EventsFun(t), this.Thread.Electrodes);
            
            %handle all off
            value = [t-this.Thread.SwitchAllOff, value];
            isterminal = [true, isterminal];
            direction = [0, direction];
        end
        
        function outVars = OdeFun(this, t, y)
            this.Thread.SetLocalState(y);
            outVars = this.Thread.GetRateLocalState';
        end
        
    end
    
    
    methods(Static)
        %The name of the simulation object stored in <this.Name>.mat
        function objName = ObjectName
            objName = 'sim';
        end
        
        function filename = CSVFilename(name)
            filename = strcat([SimulateThread.SimsFolder, name, '.csv']);
        end
        
        %TODO: Use JSON instead of these silly mat files
        function filename = SimObjectFilename(name)
            filename = strcat([SimulateThread.SimsFolder, name, '.mat']);
        end
        
        function path = SimsFolder()
            path = 'sims/';
        end
    
        %Looks for corresponding simulation data, continues from the last
        %line until t=tMax
        function ContinueSim(name, tMax)
            simObjFilename = SimulateThread.SimObjectFilename(name);
            if(~exist(simObjFilename, 'file'))
                error(strcat([simObjFilename, ' Not found!!!']))
            end
            
            load(simObjFilename)

            if(~exist(SimulateThread.ObjectName, 'var'))
                error(strcat([SimulateThread.ObjectName, ' Not found!!!']))
            end
            
            if(~exist(SimulateThread.CSVFilename(sim.Name), 'file'))
                error(strcat([SimulateThread.CSVFilename(sim.Name), ' Not found!!!']))
            end
            
            %Convert to array
            lastLine = str2num(Utils.LastLineOfFile(SimulateThread.CSVFilename(sim.Name)));
            
            nLocalVars = length(sim.Thread.GetLocalState);
            nGlobalVars = length(sim.Thread.GetGlobalState);
            
            %TODO: DRY this up with what is in SimViewer
            total = 1 + nLocalVars + nGlobalVars;
            
            %check if line has the correct number of elements
            if length(lastLine) ~= total
                error(strcat(['incorrect number of elements: ', total, ...
                    ' (expecting: ', width]));
            end
            
            %split the line
            sim.CurrentTime = lastLine(1);
            index = 2;
            
            localState = lastLine(index : index + nLocalVars - 1);
            index = index + nLocalVars;
            
            globalState = lastLine(index : index + nGlobalVars - 1);
            
            state = ThreadState(sim.Thread, sim.CurrentTime, localState, globalState);
            state.SetState;
            
            %%%Do the sim
            sim.DoSim(tMax)
        end
    end
end
