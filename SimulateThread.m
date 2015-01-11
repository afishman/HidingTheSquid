%This object stores everthing needed to run a simulation.
% - After construction use addElectrode, setElecManual setElecSelfSenser to
% include electrodes and assign behaviour
% - use plotSetup to check the discretisation
%
% - use runSim, or continueSim to run simulations. these save simulation
% date to <obj.name>.txt and object info to <obj.name>.mat
% - use extra post-simulation functions to plot results.

classdef SimulateThread < handle
    properties
        %%%Sim name, used for saving/loading
        Name='default';
        
        
        %%%Switching Properties
        %The strain source. This should take the form: [crossings, nextGlobal, strainSource] = f(obj)
        %crossings is for the events function.
        %nextGlobal outputs the new global state (logical array).
        ss = @ss1Neighbour;
        
        %The threshold (defined w.r.t the strain source)
        thresh=[0,0];      
        
        CurrentTime;
        
        Thread;     %Thread that is edited during simulation 
        
        TimeTakenToSimulate = 0;
        
        %The activation function for manual cells. Format: [state, crossings]=actiFunCyclic(t, period, tEnd)
        %if state is true manual cells will activate, otherwise they will
        %deactivate
        actiFun = @(t)actiFunBin(t, 50); %Activation function for the manual cells; output1: state, output2: event crossings
       
        
        %%% Some General properties
        RelativeErrorTolerance = 1e-4;  %ODE relative error tolerance
        SimTime = 0;  %Time taken for the sim to process;
        PointsPerSecond    = 100;   %Points per second when saving data (using linearly interpolated points) 
       
    end
    
    methods
        %%%%%%%Initial Setup Functions
        %Constructor
        function this=SimulateThread(name, thread)
            this.Name = name;
            this.Thread = thread;
        end
        
        %%%%%%%Run Functions=
        %Run the sim from t=0 until t=tMax
        function RunSim(this, tMax)
            %Delete the old text file
            if(exist(SimulateThread.CSVFilename(this.Name), 'file'))
                delete (SimulateThread.CSVFilename(this.Name))
            end
            
            this.CurrentTime = 0;
            this.TimeTakenToSimulate = 0;
            
            %Run the sim
            doSim(this, tMax)
        end
        
        %TODO: refactor this!!!
        %Looks for corresponding simulation data, continues from the last
        %line until t=tMax
        function continueSim(obj, tMax)
            %Get the filename
            filename = [obj.name, '.txt'];
            
            %Open the file
            fid = fopen(filename, 'r');
            lastLine = '';                   %# Initialize to empty
            offset = 1;                      %# Offset from the end of file
            fseek(fid,-offset,'eof');        %# Seek to the file end, minus the offset
            newChar = fread(fid,1,'*char');  %# Read one character
            while (~strcmp(newChar,char(10))) || (offset == 1)
                lastLine = [newChar lastLine];   %# Add the character to a string
                offset = offset+1;
                fseek(fid,-offset,'eof');        %# Seek to the file end, minus the offset
                newChar = fread(fid,1,'*char');  %# Read one character
            end
            fclose(fid);  %# Close the file
            
            %Convert to array
            lastLine = str2num(lastLine);
            
            %%%Separate
            %Time
            start=1;
            obj.condCurr.t = lastLine(start);
            start=start+1;
            
            %Displacement
            obj.condCurr.disp = lastLine(start:start+obj.nNodes-1);
            start = start+obj.nNodes;
            
            %Velocity
            obj.condCurr.vel = lastLine(start:start+obj.nNodes-1);
            start = start+obj.nNodes;
            
            %xi
            obj.condCurr.xi = lastLine(start:start+obj.nElem-1);
            start = start+obj.nElem;
            
            %V
            obj.condCurr.V = lastLine(start:start+obj.nElem-1);
            start = start+obj.nElem;
            
            %Global State
            obj.condCurr.elecOn = lastLine(start:start+obj.nElec-1);
            
            %%%Do the sim
            doSim(obj, tMax)
        end
        
        
        %Do the Sim
        function doSim(this, tMax)
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
        end
        
        function outVars = OdeFun(this, t, y)
            this.Thread.SetLocalState(y);
            outVars = this.Thread.GetRateLocalState';
        end
        
        
        
        
        
        %%%%%%%Delete this junk eventually
        %Switch electrodes
        function objOut = switchElectrodes(obj, t, cond)
            %Prepare output object
            objOut = obj;
            
            %Set the current conditions
            obj=setCurrCond(obj, t, cond);
            
            %The new global state
            newGlobal = false(obj.nElec,1);
            
            %Apply switching for the self-senser
            [~, newGlobalSelfSenser]=obj.ss(obj);
            newGlobal(obj.elecType==2) = newGlobal(obj.elecType==2);
            
            %And also for the manual cells
            if obj.actiFun(t)
                newGlobal(obj.elecType==1) = 1;
            else
                newGlobal(obj.elecType==1) = 0;
            end
            
            %Make sure undefined electrodes are off
            newGlobal(obj.elecType==0)=0;
            
            %Add to object
            objOut.condCurr.elecOn = newGlobal;
            
            %Define the set the of blocks that are currently on
            objOut.condCurr.blockOn=[];
            for i=1:length(newGlobal)
                if newGlobal(i)
                    objOut.condCurr.blockOn=[objOut.condCurr.blockOn, obj.electrodes{i}];
                end
            end
        end
       
        
        %The ODE Function
        function outVars=odeFun(obj, t, inVars)
            
            %Unfold vars in current conditions
            obj = setCurrCond(obj, t, inVars);
            
            %Get velocities
            vel=obj.condCurr.vel;
            
            %Work out node accelerations
            acc = nodeAcc(obj);
            
            %Set dXi's
            dXi = calcdXi(obj);
            
            %Set dVc's
            dV = calcdV(obj);
            
            %Put them together
            outVars = [vel; acc; dXi; dV];
        end
        
        %Unfold Variables
        function obj=setCurrCond(obj, t, inVars)
            %Set the time
            obj.condCurr.t=t;
            
            start=1;
            %Set the Displacements
            obj.condCurr.disp = inVars(start : start+obj.nNodes-1);
            start=start+obj.nNodes;
            
            %Set the velocities
            obj.condCurr.vel = inVars(start : start+obj.nNodes-1);
            start=start+obj.nNodes;
            
            %Set the xi's
            obj.condCurr.xi = inVars(start : start+obj.nElem-1);
            start=start+obj.nElem;
            
            %Set the Vel
            obj.condCurr.V = inVars(start : start+obj.nElem-1);
            
            
            
            
            %Set the Stretch Ratio
            obj.condCurr.lambda = obj.preStretch + diff(obj.condCurr.disp)./obj.L;
            
            %And the stretch Velocity
            obj.condCurr.lambdaDot = diff(obj.condCurr.vel)./obj.L;
            
            
        end
        
        %Material stress Function based on the current conditions
        function stress=stressMat(obj)
            %Current Conditions
            lambda = obj.condCurr.lambda;
            xi = obj.condCurr.xi;
            
            %Network A
            netAnum = obj.muA*(lambda.^2 - lambda.^-4);
            netAden = 1 - (2*lambda.^2 + lambda.^-4 - 3)./obj.Ja;
            netA = netAnum./netAden;
            
            %Network B
            netBnum = obj.muB*(lambda.^2.*xi.^-2 - lambda.^-4.*xi.^4);
            netBden = 1 - (2*lambda.^2.*xi.^-2 + lambda.^-4.*xi.^4)./obj.Jb;
            netB = netBnum./netBden;
            
            %The total stress
            stress = netA + netB;
        end
        
        %Electrical stress Function based on the current conditions
        function stress=stressElec(obj)
            %Current conditions
            lambda = obj.condCurr.lambda;
            V = obj.condCurr.V;
            
            %Electrical Stress
            stress = obj.eRel * V.^2 * obj.T^-2 .* lambda.^4;
        end
        
        %The node accelerations
        function acc = nodeAcc(obj)
            %The stress in each block
            stress = stressElec(obj) - stressMat(obj);
            %             a=stressMat(obj);a(1)
            
            %The force in each block
            forces = stress .* obj.condCurr.lambda.^-1 * obj.L*obj.T;
            
            %Inner node forces
            innerNodeForces =  -diff(forces);
            
            %And their accelerations
            innerNodeAcc = innerNodeForces./obj.TotalMass;
            
            %The accelerations (fixed boundary conditions)
            acc = zeros(obj.nNodes,1);
            acc(2:end-1) = innerNodeAcc;
        end
        
        %The rate of change of viscous stretch
        function dXi = calcdXi(obj)
            %Get the current conditons
            lambda = obj.condCurr.lambda;
            xi = obj.condCurr.xi;
            
            %Calc dXi
            num = obj.muB * obj.Jb * xi .* (lambda.^-4.*xi.^4 - lambda.^2.*xi.^-2);
            den = 6 * obj.eta * (2*lambda.^2.*xi.^-2 + lambda.^-4.*xi.^4 - 3 - obj.Jb);
            
            %Output
            dXi = num./den;
        end
        
        %The rate of change of charging
        function dV = calcdV(obj)
            %Get current conditions
            lambda = obj.condCurr.lambda;
            lambdaDot = obj.condCurr.lambdaDot;
            V = obj.condCurr.V;
            
            %Set the source voltage for each block
            Vs = zeros(obj.nElem, 1);
            Vs(obj.condCurr.blockOn)=obj.Vs;
            
            %Calculate capacitance
            cap = obj.eRel * obj.L^2 * obj.T^-1 * lambda.^4;
            
            %Calculate Rate of capacitance
            capDot = 4 * obj.eRel * obj.L^2 * obj.T^-1 * lambda.^3 .* lambdaDot;
            
            %And the rate of change of voltage
            dV = (Vs - V - V*obj.R.*capDot)./(obj.R*cap);
        end
        
        %%%%Strain Sources
        %The mean strain of the agent's cell
        function [crossings, nextGlobal, strainSource]=ssPersonal(obj)
            %Format: Thresh [r_on, r_off]            
            %stretch ratios
            lambda = obj.condCurr.lambda;
            elecOn = logical(obj.condCurr.elecOn);
            elecOff = ~elecOn;
            
            %The strain sources
            strainSource = ones(obj.nElec,1);
            for i=1:obj.nElec
                strainSource(i) = mean( lambda(obj.electrodes{i}) );
            end
            
            %For the events function
            crossings = ones(obj.nElec,1);
            crossings(elecOff) = strainSource(elecOff) - obj.thresh(1);
            crossings(elecOn) = strainSource(elecOn) - obj.thresh(2);
            
            %Apply any switching
            nextGlobal=elecOn;
            nextGlobal(elecOff & (strainSource'<=obj.thresh(1))) = 1;
            nextGlobal(elecOn & (strainSource'>=obj.thresh(2))) = 0;
        end
                
        %The mean strain of the neighbour on the left
        function [crossings, nextGlobal, strainSource]=ss1Neighbour(obj)
            %%%Format:
            %%% thresh(1) : r_on
            %%% thresh(2) : r_off
            %List stretch ratio
            lambda = obj.condCurr.lambda;
            
            %Loop through each electrode and get the strain source
            strainSource=zeros(obj.nElec,1);
            crossings=ones(obj.nElec,1);
            tolerance = 0.0000000;
            for i=2:obj.nElec
                %%%List all the elements in the neighbouring electrode
                blocks = obj.electrodes{i-1};
                
                %Calculate the strain source
                strainSource(i) = mean(lambda(blocks));              
                
                %%%And the crossings
                %Only stop if it is a self-senser
                if obj.elecType(i)==2
                    %Apply the appropriate threshold
                    if obj.condCurr.elecOn(i)
                        crossings(i) = strainSource(i)-obj.thresh(2);
                    else
                        crossings(i) = strainSource(i)-obj.thresh(1);
                    end
                end
            end
            
            
            %%%%%Also the switching
            %Prep
            elecOn = obj.condCurr.elecOn;
            elecOff =~elecOn;
            nextGlobal=elecOn;
            
            %%%The rule base
            
            %Activation Rule            
            nextGlobal(elecOff & (strainSource' >= obj.thresh(1)) ) = 1;
            
            %Deactivation Rule
            nextGlobal(elecOn & (strainSource' <= obj.thresh(2)) ) = 0;
        end
        
        %Deprecated: The mean strain of both neighbors
        function [crossings, nextGlobal, strainSource]=ss2Neighbour(obj)
            %%%Format:
            %%% thresh(1): lower On
            %%% thresh(2): lower Off
            
            %List stretch ratio
            lambda = obj.condCurr.lambda;
            
            
            
            %%%Get the strain source
            %The first Cell
            strainSource=zeros(obj.nElec,1);
            
            %The middle ones
            for i=2:obj.nElec-1
                %Get all the neighboring blocks
                blocks = [obj.electrodes{i-1}, obj.electrodes{i+1}];
                
                %Set the strain source
                strainSource(i) = mean(lambda(blocks));
            end
            
            %The end one
            strainSource(end) = mean(lambda(obj.electrodes{end-1}));
            
            %Crossings for the event solver
            crossings = (obj.thresh(1) - strainSource) .* (obj.thresh(2) - strainSource);
            
            
            
            %%% And the switching
            nextGlobal = zeros(1,obj.nElec);
            nextGlobal(...
                (strainSource>obj.thresh(1)) & ...
                (strainSource<obj.thresh(2))...
                )=1;
        end
        
        %Deprecated: Estimate if each one is on or off
        function [crossings, nextGlobal] = ss2NeighbourV2(obj)
            %%%Format:
            %%% thresh(1): on/off
            %List stretch ratio
            lambda = obj.condCurr.lambda;
            
            %Get the mean strain of each electrode
            for i=1:obj.nElec
                meanLambda(i) = mean(lambda(obj.electrodes{i}));
            end
            
            %For the event function
            crossings = meanLambda'-obj.thresh;
            
            %See if they are on/off
            elecState = zeros(obj.nElec,1);
            elecState(meanLambda>obj.thresh(1))=1;
            
            %Count the number of actuated ones
            nNeighOn = zeros(obj.nElec,1);
            nNeighOn(1)       = elecState(2);
            nNeighOn(2:end-1) = elecState(1:end-2) + elecState(3:end);
            nNeighOn(end)     = elecState(end-1);
            
            %And the switching
            nextGlobal = zeros(1,obj.nElec);
            nextGlobal(nNeighOn==1) = 1;
        end
        
        %Version 3: Double thresholds. Nice :)
        function [crossings, nextGlobal, strainSource] = ss2NeighbourV3(obj)
            %%%Format:
            %%% Thresh(1:2): th(1)< TURN ON <th(2)
            %%% Thresh(3:4): th(3)< TURNOFF <th(4)
            
            crossings=zeros(obj.nElec,1);
            
            %%%List stretch ratio
            lambda = obj.condCurr.lambda;
            
            %%%Get the strain source
            %The first Cell
            strainSource=zeros(obj.nElec,1);
            
            %The middle ones
            for i=2:obj.nElec-1
                %Get all the neighboring blocks
                blocks = [obj.electrodes{i-1}, obj.electrodes{i+1}];
                
                %Set the strain source
                strainSource(i) = mean(lambda(blocks));
            end
            
            %The last cell
            blocks = [obj.electrodes{end-1}, obj.electrodes{end}];
            strainSource(obj.nElec) = mean(lambda(blocks));
            
            %%%Calculate crossings & next Global
            for i=1:obj.nElec
                %Get the right threshold
                if ~obj.condCurr.elecOn(i)
                    thresh = obj.thresh(1:2);
                else
                    thresh = obj.thresh(3:4);
                end
                
                %Set the crossings
                crossings(i) = (thresh(1) - strainSource(i)) .* (thresh(2) - strainSource(i));
                
                %And the next Global
                if (thresh(1)<=strainSource(i)) && (strainSource(i)<=thresh(2))
                    nextGlobal(i)=1;
                else
                    nextGlobal(i)=0;
                end
            end
        end
    end
    
    
    methods(Static)
        function objName = ObjectName
            objName = mfilename;
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
    
    end
end
