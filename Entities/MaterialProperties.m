classdef MaterialProperties < handle    
    properties
        %Material properties
        Density;    %Material Densoty (kg/m3)
        RelativeDielectricConstant; %Relative Dielectric Constant (Whatever it is)
        NaturalThickness;
    end
    
    methods
        function this = MaterialProperties(density, relativeDielectricConstant, naturalThickness)
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
        % For VHB4910
        function this = Default()
            density = 960;
            relativeDielectricConstant = 4.5 * 8.854187817 * 10^-12;
            naturalThickness = 0.5e-3;
            
            this = MaterialProperties(density, relativeDielectricConstant, naturalThickness);
        end
    end
end

