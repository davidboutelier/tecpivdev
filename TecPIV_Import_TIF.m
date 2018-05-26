function [NumberImages,ImageWidth,ImageHeight] = TecPIV_Import_TIF(IPath,ThisDataSetNumber,TecPIVFolder)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    DataFolder=IPath{ThisDataSetNumber,1}; % e.g Cam_1/Raw
    PathData=IPath{ThisDataSetNumber,2};
    ProjectName=IPath{ThisDataSetNumber,3};
    FullDataFolder=fullfile(PathData,ProjectName,DataFolder);

    [DataFileName,DataPathName,~]=uigetfile('.tif','Import images','MultiSelect','on');

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
    
    Images = cell(1,NumberImages);

    obj = ProgressBar(NumberImages,'Title','Importing images');
    for i=1:NumberImages           
            Images{i}=strcat(cellstr(DataPathName), DataFileName(i));
            name=strcat('IMG_',num2str(i),'.tif');
            %easycopySilent(char(Images{i}), fullfile(FullDataFolder,name));
            source=char(Images{i});
            destination=fullfile(FullDataFolder,name);
            copyfile(source,destination);
            
    obj.step([], [], []);    
    end
    obj.release();
    
    % get size from last image
    I0=imread(fullfile(FullDataFolder,name));
    SizeI0=size(I0);
    ImageHeight=SizeI0(1,1);
    ImageWidth=SizeI0(1,2);
    
    disp(['-> ' num2str(NumberImages) ' TIF images imported'])
    disp(['-> Image Height is ' num2str(ImageHeight) ' pixels'])
    disp(['-> Image Width is ' num2str(ImageWidth) ' pixels'])
    
    %go back to project folder
    cd(fullfile(PathData,ProjectName));
        
        

end

