classdef TypeIIISimAnalysis
    
    methods(Static)
        function gen()
            a = SimViewer('rOnLower');
            a.GenReport;
            
            a = SimViewer('rOffUpper');
            a.GenReport;
            
            a = SimViewer('rOnUpper');
            a.GenReport;
            
            a = SimViewer('rOffLower');
            a.GenReport;
        end
        
        
        function run()
            len=40;
            
            
            sim = CreateSimSS(true, [0,0,0], [1,0,0]);
            sim.Name = 'rOnLower';
            sim.RunSim(len);
            
            sim = CreateSimSS(true, [1,1,0], [1,1,1]);
            sim.Name = 'rOffUpper';
            sim.RunSim(len);
            
            sim = CreateSimSS(true, [1,1,1], [1,1,0]);
            sim.Name = 'rOnUpper';
            sim.RunSim(len);
            
            sim = CreateSimSS(true, [1,1,0], [0,1,0]);
            sim.Name = 'rOffLower';
            sim.RunSim(len);
            
            % sim = CreateSim(30);
            % sim.RunSim(len);
            
            % SimulateThread.ContinueSim('TypeIIISimAnalysis_30cells', len);
            %
            % sim = CreateSim(29);
            % sim.RunSim(len);
            %
            % sim = CreateSim(28);
            % sim.RunSim(len);
            
        end
        
        function sim = CreateSimSS(otherCellsActive, ssArrangement, currStateArrangement)
            
            ssArrangement = sort(ssArrangement);
            currStateArrangement = sort(currStateArrangement);
            
            
            
            if(otherCellsActive)
                ssArrangement = [ssArrangement, ones(1,27)];
                currStateArrangement = [currStateArrangement, ones(1,27)];
            else
                ssArrangement = [ssArrangement, zeros(1,27)];
                currStateArrangement = [currStateArrangement, zeros(1,27)];
            end
            
            nCellsActive = sum(ssArrangement);
            
            
            sim = CreateSim(nCellsActive);
            
            [activeStretch, passiveStretch] = sim.Thread.CalculateSteadyStateStretches(nCellsActive);
            
            count=0;
            for electrode = sim.Thread.Electrodes
                count=count+1;
                
                if(ssArrangement(count))
                    electrode.SetStretchRatio(activeStretch);
                    electrode.SetXi(activeStretch);
                    electrode.SetVoltage(electrode.RCCircuit.SourceVoltage);
                else
                    electrode.SetStretchRatio(passiveStretch);
                    electrode.SetXi(passiveStretch);
                    electrode.SetVoltage(0);
                end
                
                if(currStateArrangement(count))
                    type = ElectrodeTypeEnum.ExternallyControlled;
                else
                    type = ElectrodeTypeEnum.LocallyControlled;
                end
                electrode.Type = type;
                %     for element = electrode.Elements
                %         element.Type = type;
                %     end
                
                
                
                for element = sim.Thread.GetPassiveSection(electrode.EndVertex.RightElement)
                    element.SetStretchRatio(passiveStretch);
                    element.Xi=(passiveStretch);
                end
                
            end
            
            % close all
            % sim.Thread.Plot;
            % error(';')
            
            
        end
        
        function sim = CreateSim(nCellsActive)
            
            %These are optimal paramters
            %TODO: automate the creation of optimally spaced threads
            preStretch = 2.5;
            nCells = 30;
            cellLengthAtPrestretch = 20e-3 * preStretch;
            spacingAtPrestretch = 40e-3 * preStretch;
            
            tOn = 0; tOff = 200;
            switchingModelExternal = StepModel(tOn, tOff);
            switchingModelLocal = LocalAlwaysOffModel;
            
            %initialises a thread with equally spaced, locally controlled electrodes
            thread = Thread.ConstructThreadWithSpacedElectrodes( ...
                preStretch, ...
                cellLengthAtPrestretch, ...
                nCells, ...
                spacingAtPrestretch, ...
                switchingModelLocal, ...
                switchingModelExternal, ...
                GentParams.Koh2012, ...
                @(x)FiberConstrainedElement(x, 1));
            
            thread.SetAllElectrodeTypes(ElectrodeTypeEnum.ExternallyControlled);
            thread.RCCircuit.Resistance = 1e7;
            
            for i = length(thread.Electrodes) - nCellsActive+1: length(thread.Electrodes)
                thread.Electrodes(i).Type = ElectrodeTypeEnum.LocallyControlled;
            end
            
            name = strcat([mfilename, '_', int2str(nCellsActive), 'cells']);
            sim = SimulateThread(name, thread);
            
        end
    end
end