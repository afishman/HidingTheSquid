classdef SimAnimator
    %SIMANIMATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Viewer;
        
        CuttleCodedImagePath = 'Static/laura_cuttle_coded.bmp';
        CuttleCodedImage;
        
        CuttleColor1 = [47 ,117,117];
        CuttleColor2 = [119,200,185];

        MainBodyPixelCode = 64; % Indicates the pixel value on the main vody of the cuttlefish
        MainBodyColor;
        
        HeadPixelCode = 107;
        HeadColor;
        
        FinPixelCode = 161;
        FinColor;
    end
    
    methods
        function this=SimAnimator(viewer)
            this.Viewer = viewer;
            this.CuttleCodedImage = Utils.ImportBMPIntoBW(this.CuttleCodedImagePath);
            
            this.MainBodyColor = this.CuttleColor1;
            this.HeadColor = this.CuttleColor2;
            this.FinColor = this.CuttleColor1;
        end
        
        
        function MakeMovie(this)
            framerate = 30;
            speed = 1;
            
            
        end
        
        
        %mask(i,j,k) == true means that pixel should be replaced with
        %corresponding value in the striped plot
        function mask = CuttleMask(this)
            mask = uint8(this.CuttleCodedImage==this.MainBodyPixelCode);
            mask(:,:,2) = mask(:,:,1);
            mask(:,:,3) = mask(:,:,1);
        end
        
        %Converts to the coded image to rgb colors
        function img = ColorCodedCuttlefishImage(this)
            %Initialise 3D Image
            s = [size(this.CuttleCodedImage),3];
            img = zeros(s);
            img(:,:,1) = this.CuttleCodedImage;
            img(:,:,2) = this.CuttleCodedImage;
            img(:,:,3) = this.CuttleCodedImage;
                        
            img=this.ColorByNumber(img, this.CuttleCodedImage, this.MainBodyPixelCode, this.MainBodyColor);
            img=this.ColorByNumber(img, this.CuttleCodedImage, this.HeadPixelCode, this.HeadColor);
            img=this.ColorByNumber(img, this.CuttleCodedImage, this.FinPixelCode, this.FinColor);
            
            %Make uint8
            img= uint8(img);
            
            image(img);
        end
       
        %Colors a 3D image using a 2D codemap
        %pixels equal to the code are colored ane are 0 otherwise
        function img3D=ColorByNumber(this, img3D, codemap, code, color)
            codemapSize = size(codemap);
            img3DSize = size(img3D);
            
            if(codemapSize(1)~=img3DSize(1) || codemapSize(2)~=img3DSize(2))
                error('img3D and codemap must have the same x-y dimensions');
            end
            
            %The mask
            mask = codemap == code;
            mask(:,:,2) = mask(:,:,1);
            mask(:,:,3) = mask(:,:,1);
            
            %3D image size
            s = [size(codemap), 3]; 
            
            %A 3D block of color
            colorBlock = zeros(s);
            colorBlock(:,:,1) = color(1);
            colorBlock(:,:,2) = color(2);
            colorBlock(:,:,3) = color(3);
            
            img3D(mask) = colorBlock(mask);
        end
        
        %%%%%%%%A quadratic bezier
        function linePoints = bezQuad(this)
            
            %The number of ppoints
            nPts=100;
            
            %The control points
            P=[
                0,0;
                -1,0;
                2,2;
                ];
            
            t=linspace(0,1,nPts);
            
            linePoints = Point2D.empty;
            
            %Generate the quadratic bezier
            for i=1:length(t)
                currT = t(i);
                point = (1-currT) .* ((1-currT).*P(1,:) + currT.*P(2,:))...
                    + currT.*( (1-currT).*P(2,:)...
                    + currT.*P(3,:) );
                
                linePoints(end+1) = Point2D(point(1), point(2));
            end
            
        end
        
        %Plot a filled polygon, given a line, start and end
        %TODO: Add input args
        function PlotFilled(this)
            handle = gca;
            x1 = 0;
            x2 = 1;
            color = 'r';
            
            theLine = this.bezQuad;
            
            firstHalf = this.bezQuad;
            shift = Point2D(x1, 0);
            arrayfun(@(x) x.Transpose(shift), firstHalf);
            
            secondHalf = fliplr(this.bezQuad);
            shift = Point2D(x2, 0);
            arrayfun(@(x) x.Transpose(shift), secondHalf);
            
            polygonPoints = [firstHalf, secondHalf];
            
            x = arrayfun(@(x) x.X, polygonPoints);
            y = arrayfun(@(x) x.Y, polygonPoints);
            
            fill(x,y,color, 'Parent', handle, 'EdgeColor', color)
        end
        
    end
    
end

