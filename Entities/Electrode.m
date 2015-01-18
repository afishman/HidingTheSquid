classdef Electrode < handle
    %ELECTRODE represents a section of material that is covered with
    %compliant, conducting electode and hooked up to a RC circuit
    %   Detailed explanation goes here
    %TODO: Include a stub element
    
    properties
        Elements = DissertationElement.empty; 
        Type = ElectrodeTypeEnum.Undefined; %Type: ElectrodeTypeEnum
        
        RCCircuit;
        
        NextElectrode;
        PreviousElectrode;
        
        %The electrode only actually uses one of these 
        SwitchingModelLocal;
        SwitchingModelExternal;
        
        %This is only public so I can load data into it
        GlobalState;
    end
    
    properties (SetAccess = private)
        StartVertex;
        EndVertex;
    end
    
    methods
        function this = Electrode(elements, electrodeType, rcCircuit, switchingModelLocal, switchingModelExternal)
            %TODO: Check consistency
            this.Elements = elements;
            this.Type = electrodeType;
            this.RCCircuit = rcCircuit;
            this.SwitchingModelLocal = switchingModelLocal;
            this.SwitchingModelExternal = switchingModelExternal;
            
            %TODO: These should really be get methods
            %TODO: Origin is better here
            this.StartVertex = Vertex(Inf, 0, 0);
            this.EndVertex = Vertex(-Inf, 0, 0);
            for element = this.Elements
                if(element.StartVertex.Origin < this.StartVertex.Origin)
                    this.StartVertex = element.StartVertex;
                end
                
                if(element.EndVertex.Origin > this.EndVertex.Origin)
                    this.EndVertex = element.EndVertex;
                end
                
                element.RCCircuit = this.RCCircuit;
            end
            
            this.GlobalState = false;
        end
        
        function vertices = Vertices(this)
            vertices = this.StartVertex;
            
            vertex = this.StartVertex;
            while(vertex ~= this.EndVertex)
                vertex = vertex.Next;
                vertices = [vertices, vertex];
            end
        end
        
        function model = SwitchingModel(this)
            switch(this.Type)
                case ElectrodeTypeEnum.LocallyControlled
                    model = this.SwitchingModelLocal;
                    
                case ElectrodeTypeEnum.ExternallyControlled
                    model = this.SwitchingModelExternal;
                    
                case ElectrodeTypeEnum.Undefiuned
                    model = ExternalAlwaysOffModel;
            end
        end
        
        %Note: 'time' is unused for local sensing cells. If it needs the time it
        %should be an externally controlled cell!
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
        
        %For plotting purposes only
        function source = Source(this)
            if this.Type == ElectrodeTypeEnum.LocallyControlled
                source = this.SwitchingModel.Source(this);
            else
                source = 0;
            end
        end
        
        function dVoltage = DVoltage(this)
            dVoltage = arrayfun(@(x) x.DVoltage(this.GlobalState), this.Elements);
        end
        
        %This works well enough, could've also measured the stretch between
        %the start/end vertex
        function stretchRatio = StretchRatio(this)
            stretchRatio = mean(arrayfun(@(x) x.StretchRatio, this.Elements));
        end
        
        function electrodes = Neighbours(this)
            electrodes = Electrode.empty;
            
            if(~isempty(this.NextElectrode))
                electrodes(end+1) = this.NextElectrode;
            end
            
            if(~isempty(this.PreviousElectrode))
                electrodes(end+1) = this.PreviousElectrode;
            end
        end
    end
end
