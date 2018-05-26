function [NumberImages,ImageWidth,ImageHeight] = TecPIV_Import_DNG(IPath,ThisDataSetNumber,TecPIVFolder)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    DataFolder=IPath{ThisDataSetNumber,1}; % e.g Cam_1/Raw
    PathData=IPath{ThisDataSetNumber,2};
    ProjectName=IPath{ThisDataSetNumber,3};
    FullDataFolder=fullfile(PathData,ProjectName,DataFolder);

    [DataFileName,DataPathName,~]=uigetfile('.dng','Import images','MultiSelect','on');
    
    % if only one Calibration image, DataFileName is not a cell array. Make it
    % a cell array with one single entry containing the DataFileName

    NumberImageTest = ischar(DataFileName);
    if NumberImageTest == 1 %DataFileName is character array 
        NumberImages = 1;
        OldDataFileName=DataFileName;
        DataFileName=cell(1,1);
        DataFileName{1,1}=OldDataFileName;
    else
        SizeDataSet=size(DataFileName);
        NumberImages=SizeDataSet(2);
    end

    % load the rgb2xyz mat
    %load(fullfile(TecPIVFolder,'rgb2xyz.mat'),'rgb2xyz');

    Images = cell(1,NumberImages); %Preallocate array of image addresses
    
    obj = ProgressBar(NumberImages,'Title', 'Importing images');
    for i = 1:NumberImages
        
        Images(i)=strcat(cellstr(DataPathName), DataFileName(i));
        name=strcat('IMG_',num2str(i),'.tif');
        
        meta_info = imfinfo(char(Images(i))); %get the metadata of current image
        meta_info_subIFD=meta_info.SubIFDs;
        CFA_type = meta_info_subIFD{1}.PhotometricInterpretation;
        %xyz2cam = meta_info.ColorMatrix2;
        %xyz2cam=[xyz2cam(1) xyz2cam(2) xyz2cam(3); xyz2cam(4) xyz2cam(5) xyz2cam(6); xyz2cam(7) xyz2cam(8) xyz2cam(9)];
            
        if ismac
            % Code to run on Mac plaform
            system(['/usr/local/bin/exiftool -struct -j ' char(Images(i)) ' > Exif_File']);
        elseif isunix
            % Code to run on Linux plaform
            system(['exiftool -struct -j ' char(Images(i)) ' > Exif_File']);
        elseif ispc
            % Code to run on Windows platform
            system([TecPIVFolder '\exiftool -struct -j ' char(Images(i)) ' > Exif_File']); % use standalon exiftool to extract exif data into a file
        else
            disp('Platform not supported')
        end
        
        % load the jason exif file
        Exif=loadjson('Exif_File');
            
        % save a copy of the exif files
        destination=fullfile(FullDataFolder,strcat('Exif_',num2str(i),'.txt'));
        copyfile('Exif_File',destination);
            
        % get CFA Pattern from exif
        CFAPattern=Exif{1,1}.CFAPattern; 
            
        % convert CFA Pattern to matlab key for CFA Pattern
        if strcmp(CFAPattern, '[Red,Green][Green,Blue]') == 1
            CFAPattern='rggb'; 
        end
        
        % TO DO: make other CFA patterns...
            
        ScaleFactor=Exif{1,1}.ScaleFactor35efl;
            
        switch ScaleFactor
            case 1.6 % Canon APSC
                myhandles.SensorWidth=22.2;
                myhandles.SensorHeight=14.8;
                    
            case 1 % full frame (Nikon D810)
                myhandles.SensorWidth=35.9;
                myhandles.SensorHeight=24;
               
            % TO DO: make other sensor sizes available...     
            otherwise
                fprintf(1,'WARNING: No scale factor available to determine the physical size of the sensor.\n');
        end
   
        FOV=Exif{1,1}.FocalLength;
        FOV=FOV(1:length(FOV)-3);% remove unit (mm)
        FOV = str2double(FOV);
        myhandles.FOV=FOV;
        
        % read the tiff file within DNG
        warning('off','all');
        cd(DataPathName);
        t = Tiff(char(DataFileName(i)),'r');
        offsets = getTag(t,'SubIFD');
        setSubDirectory(t,offsets(1));
   
        I0 = t.read; 
        t.close; 
            
        if strcmp(CFA_type, 'CFA') == 1 % if DNG is not demosacized
            % Crop to valid pixels
            x_origin = meta_info.SubIFDs{1}.ActiveArea(2)+1; %+1 due to MATLAB indexing
            width = meta_info.SubIFDs{1}.DefaultCropSize(1);
            y_origin = meta_info.SubIFDs{1}.ActiveArea(1)+1;
            height = meta_info.SubIFDs{1}.DefaultCropSize(2);
            I0 = I0(y_origin:y_origin+height-1,x_origin:x_origin+width-1);
     
            if strcmp(CFAPattern, 'rggb') == 1
                I0=demosaic(I0,CFAPattern);
            else
            % TO DO: Import raw files not rggb....
            end
        end
        
        I0=imadjust(uint16(rgb2gray(I0)));
            
        % save raw image as 16-bit tiff
        cd(FullDataFolder);
        imwrite(I0,name,'tiff');
        %disp(['Writing file: ' name])
            
        %go back to project folder
        cd(fullfile(PathData,ProjectName));
          
        if exist('Exif_file','file')
            delete('Exif_file'); 
        end
%         
%         % Display progress
%         if mod(i,progressStepSize)==0
%             ppm.increment();
%         end

    obj.step([], [], []);    
    end
    obj.release();
    
    SizeImage=size(I0);
    ImageHeight=SizeImage(1,1);
    ImageWidth=SizeImage(1,2);
    
    disp(['-> ' num2str(NumberImages) ' DNG images imported'])
    disp(['-> Image Height is ' num2str(ImageHeight) 'pixels'])
    disp(['-> Image Width is ' num2str(ImageWidth) 'pixels'])

%clear t;
    
end

