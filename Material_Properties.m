classdef Material_Properties < handle
    %Defaults here are for VHB4910
    
    properties
        %Material properties
        Density;    %Material Densoty (kg/m3)
        RelativeDielectricConstant; %Relative Dielectric Constant (Whatever it is)
        NaturalThickness;
    end
    
    methods
        function this = Material_Properties(density, relativeDielectricConstant, naturalThickness)
            if(this.Density<0)
                error('density must be non-zero')
            end
            
            if(this.RelativeDielectricConstant<0)
                error('density must be non-zero')
            end
            
            if(naturalThickness < 0 )
                error('natural thicknesss must be > 0');
            end
            
            this.Density = density;
            this.RelativeDielectricConstant = relativeDielectricConstant;
            this.NaturalThickness = naturalThickness;
        end
        
        
    end
    
    methods (Static)
        function this = Default()
            density = 960;
            relativeDielectricConstant = 4.5 * 8.854187817 * 10^-12;
            naturalThickness = 0.5e-3;
            
            this = Material_Properties(density, relativeDielectricConstant, naturalThickness);
        end
    end
end

