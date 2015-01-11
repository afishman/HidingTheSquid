classdef Electrode < handle
    %ELECTRODE represents a section of material that is covered with
    %electode and hooked up to a RC circuit
    %   Detailed explanation goes here
    %TODO: Include a stub element
    
    properties
        Elements = DissertationElement.empty; 
        Type = ElectrodeTypeEnum.Undefined;
        
        RCCircuit;
        
        NextElectrode;
        PreviousElectrode;
        SwitchingModel;
        
        %TODO: allow electrode to load its own data
        %This is only public so I can load data into it
        GlobalState;
    end
    
    properties (SetAccess = private)
        StartVertex;
        EndVertex;
    end
    
    methods
        function this = Electrode(elements, electrodeType, rcCircuit, switchingModel)
            %TODO: Check consistency
            this.Elements = elements;
            this.Type = electrodeType;
            this.RCCircuit = rcCircuit;
            this.SwitchingModel = switchingModel;
            
            %TODO: These should really be get methods
            %TODO: Origin is better here
            this.StartVertex = Vertex(Inf, 0, 0);
            this.EndVertex = Vertex(-Inf, 0, 0);
            for element = this.Elements
                if(element.StartVertex.Position < this.StartVertex.Position)
                    this.StartVertex = element.StartVertex;
                end
                
                if(element.EndVertex.Position > this.EndVertex.Position)
                    this.EndVertex = element.EndVertex;
                end
                
                element.RCCircuit = this.RCCircuit;
            end
            
            this.GlobalState = false;
        end
        
        %Note: 'time' is unused for local sensing cells. If it needs the time it
        %should be an externally controlled cell!
        %TODO: This is abit bodge, the program structure should
        %ensure the switching model works well with electrode type
        function UpdateGlobalState(this, time)
            switch(this.Type)
                case ElectrodeTypeEnum.ExternallyControlled
                    this.GlobalState = this.SwitchingModel.State(time);
                    
                case ElectrodeTypeEnum.LocallyControlled
                    this.GlobalState = this.SwitchingModel.State(this);
                    
                case ElectrodeTypeEnum.Undefined
                    this.GlobalState = false;
            end
        end
        
        function [value, isTerminal, direction] = EventsFun(this, time)
            switch(this.Type)
                case ElectrodeTypeEnum.ExternallyControlled
                    value = this.SwitchingModel.EventsFunValue(time);
                    isTerminal = this.SwitchingModel.EventsFunIsTerminal(time);
                    direction = this.SwitchingModel.EventsFunDirection(time);
                    
                case ElectrodeTypeEnum.LocallyControlled
                    value = this.SwitchingModel.EventsFunValue(this);
                    isTerminal = this.SwitchingModel.EventsFunIsTerminal(this);
                    direction = this.SwitchingModel.EventsFunDirection(this);
                    
                case ElectrodeTypeEnum.Undefined
                    value = 1;
                    isTerminal = 0;
                    direction = 1;
            end
        end
        
        
        
        function dVoltage = DVoltage(this)
            dVoltage = arrayfun(@(x) x.DVoltage(this.GlobalState), this.Elements);
        end
        
        function stretchRatio = StretchRatio(this)
            stretchRatio = mean(arrayfun(@(x) x.StretchRatio, this.Elements));
        end
        
        function electrodes = Neighbours(this)
            electrodes = [];
            
            if(~isempty(this.NextElectrode))
                electrodes = [electrodes, this.NextElectrode];
            end
            
            if(~isempty(this.PreviousElectrode))
                electrodes = [electrodes, this.PreviousElectrode];
            end
        end
    end
end

