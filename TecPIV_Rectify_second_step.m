function [RectFn2] = TecPIV_Rectify_second_step(DataSets,DataSetNumber,Frame,RectMethod,Order,RES)
%UNTITLED2 Summary of this function goes here
%   Rectfy the calibration image. outputs the Resolution and
%   RectficationFunction
%
message=sprintf('Starting calculation of rectification function...');
disp(message);

DataFolder=DataSets{DataSetNumber,1}; 
TecPIVFolder=DataSets{DataSetNumber,2};
ProjectName=DataSets{DataSetNumber,3};

% load image to rectify
FramePath=fullfile(TecPIVFolder,ProjectName,DataFolder,['IMG_' num2str(Frame) '.tif']);
I=imread(FramePath);

% load control points
ControlPointsPath=fullfile(TecPIVFolder,ProjectName,DataFolder,'ControlPointsRectfied_1.mat');

A = load(ControlPointsPath, ['dX']); SNames = fieldnames(A);
dX=A.(SNames{1});
    
A = load(ControlPointsPath, ['dY']); SNames = fieldnames(A);
dY=A.(SNames{1});
    
A = load(ControlPointsPath, ['n_sq_x']); SNames = fieldnames(A); 
n_sq_x=A.(SNames{1});
    
A = load(ControlPointsPath, ['n_sq_y']); SNames = fieldnames(A);
n_sq_y=A.(SNames{1});
    
A=load(ControlPointsPath, ['grid_pts']); SNames = fieldnames(A); 
x = A.(SNames{1});


% load the window sizes
A = load(ControlPointsPath, ['wintx']); SNames = fieldnames(A);
wintx=A.(SNames{1});

A = load(ControlPointsPath, ['winty']); SNames = fieldnames(A);
winty=A.(SNames{1});


%define number of point instead of number of squares
n_pt_x=n_sq_x+1;
n_pt_y=n_sq_y+1;

% Coordinates of central point
nO=n_pt_x*(n_pt_y-1)/2+(n_pt_x+1)/2;
xO=x(1,nO); yO=x(2,nO);

% coordinates new first point
        TX1= xO - ((n_sq_x)/2)*dX*RES;
        TY1= yO - ((n_sq_y)/2)*dY*RES;

        TY=(repmat((1:n_pt_y),n_pt_x,1)-1).*(dY*RES)+TY1; % grid with Y coordinates target
        TX=(repmat((1:n_pt_x)',1,n_pt_y)-1).*(dX*RES)+TX1; % grid with X coordinates target
        tx=(reshape(TX,[],1))'; % vector with all the X coordinates target
        ty=(reshape(TY,[],1))'; % vector with all the Y coordinates target
        tx(2,:)=ty;
        
        % Note these 2 figures are for testing - remove when working
        % create new figure with points in original image (blue crosses) and
        % target grid (red cross)
        htemp=figure(10);
        plot(xO,yO,'Marker','o','MarkerFaceColor','red');
        set(gca,'YDir','reverse');
        hold on;
        plot(x(1,:),x(2,:),'+b');
        hold on;
        axis equal;
        hold on;
        plot(tx(1,:),tx(2,:),'+r');
        filename=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectification2.pdf');
        %print(htemp,'-dpdf',filename)
        close(htemp)

        % create new figure with vectors from points to where it needs to
        % go
        htemp=figure(10);
        quiver(x(1,:),x(2,:),tx(1,:)-x(1,:),tx(2,:)-x(2,:),0);
        set(gca,'YDir','reverse');
        hold on;
        axis equal;
        filename=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectification-Vector2.pdf');
        %print(htemp,'-dpdf',filename)
        close(htemp)
        
        message=sprintf('Calculating rectification function...'); 
        disp(message)
        
        RectFn2=cp2tform(x',tx','polynomial',Order);
                   
        message=sprintf('Rectifying calibration image...'); 
        disp(message)
        ImB = imtransform(I,RectFn2,'bilinear','FillValues', Inf);
        
        % Save the Rectfication function
        message=sprintf('Saving rectification function...'); 
        disp(message)
        SaveFile=fullfile(TecPIVFolder,ProjectName,DataFolder,'RectificationFunction2.mat');
        if exist(SaveFile,'file')
        save(SaveFile,...
            'RES',...
            'RectFn2','-append');
        else
            save(SaveFile,...
            'RES',...
            'RectFn2');
        end
        
        % Save the rectified calibration image in the calibration folder
        message=sprintf('Saving rectified calibration image...\n'); 
        disp(message)
        
        
        cd(fullfile(TecPIVFolder,ProjectName,DataFolder));
        mkdir('Rectified2');
        cd(fullfile(TecPIVFolder,ProjectName));
        
        name=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectified2',['IMG_' num2str(Frame) '.tif']);
        imwrite(ImB,name,'tiff','Compression','none');
       
   
end

