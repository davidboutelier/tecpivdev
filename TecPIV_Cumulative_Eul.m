function TecPIV_Cumulative_Eul(DataSets,ThisDataSetNumber)

%% Parameters from GUI
DatasetFolder = DataSets{ThisDataSetNumber,1};
PathData = DataSets{ThisDataSetNumber,2};
ProjectID = DataSets{ThisDataSetNumber,3};
        
NumberImages = DataSets{ThisDataSetNumber,4};
ImageWidth = DataSets{ThisDataSetNumber,5};
ImageHeight = DataSets{ThisDataSetNumber,6};
TimeInc = DataSets{ThisDataSetNumber,7};
ImageInc = DataSets{ThisDataSetNumber,8};
StartNumber = DataSets{ThisDataSetNumber,9}; 
EndNumber = DataSets{ThisDataSetNumber,10}; 

Nsteps=(EndNumber-StartNumber)/ImageInc + 1;

%% create folder if it doesn't exist already.
Framepath=fullfile(PathData,ProjectID,DatasetFolder);
cd(Framepath);
if ~exist('Eulerian_Sum', 'dir')
  mkdir('Eulerian_Sum');
end
cd(fullfile(PathData,ProjectID));

%% Display progress
progressStepSize = 1;
ppm = ParforProgMon('Summing vector fields:  ', Nsteps, progressStepSize, 500, 40);


for j=1:Nsteps
    F=StartNumber+(j-1)*ImageInc; % Framenumber
    % load vector file and get size of vector field
    load(fullfile(Framepath, ['Vector_' num2str(F) '.mat']),'X','Y','U','V');
    
    if j == 1
        Xc=X;
        Yc=Y;
        Uc=U;
        Vc=V;
        SaveName=fullfile(Framepath, 'Eulerian_Sum',['Vector_Cum_' num2str(F) '.mat']);
        save(SaveName,'X','Y','U','V'); 
        clear X Y U V 
    else
        Xc=X;
        Yc=Y;
        Uc=Uc+U;
        Vc=Vc+V;
        
        U=Uc;
        V=Vc;
        
        SaveName=fullfile(Framepath, 'Eulerian_Sum',['Vector_Cum_' num2str(F) '.mat']);
        save(SaveName,'X','Y','U','V'); 
        clear X Y U V 
    end
    
    if mod(j,progressStepSize)==0
        ppm.increment();
    end
    
end
ppm.delete()