function [RES,RectFn,tx,wintx,winty] = TecPIV_Rectify(DataSets,DataSetNumber,Frame,RectMethod,Order)
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
ControlPointsPath=fullfile(TecPIVFolder,ProjectName,DataFolder,'CalibrationPoints.mat');
A = load(ControlPointsPath, ['dX_' num2str(Frame)]); SNames = fieldnames(A);
dX=A.(SNames{1});
    
A = load(ControlPointsPath, ['dY_' num2str(Frame)]); SNames = fieldnames(A);
dY=A.(SNames{1});
    
A = load(ControlPointsPath, ['n_sq_x_' num2str(Frame)]); SNames = fieldnames(A); 
n_sq_x=A.(SNames{1});
    
A = load(ControlPointsPath, ['n_sq_y_' num2str(Frame)]); SNames = fieldnames(A);
n_sq_y=A.(SNames{1});
    
A=load(ControlPointsPath, ['x_' num2str(Frame)]); SNames = fieldnames(A); 
x = A.(SNames{1});


% load the window sizes
A = load(ControlPointsPath, ['wintx_' num2str(Frame)]); SNames = fieldnames(A);
wintx=A.(SNames{1});

ControlPointsPath=fullfile(TecPIVFolder,ProjectName,DataFolder,'CalibrationPoints.mat');
A = load(ControlPointsPath, ['winty_' num2str(Frame)]); SNames = fieldnames(A);
winty=A.(SNames{1});

%define number of point instead of number of squares
n_pt_x=n_sq_x+1;
n_pt_y=n_sq_y+1;

    if mod(n_sq_x,2)==0 && mod(n_sq_y,2)==0
    
        % both numbers of squares are even (therefore numbers of points are
        % odd)

        nO=n_pt_x*(n_pt_y-1)/2+(n_pt_x+1)/2;
        nA=nO-(n_pt_x)-1; % point number of four points around the center
        nB=nO-(n_pt_x)+1;
        nC=nO+(n_pt_x)+1;
        nD=nO+(n_pt_x)-1; 

        xO=x(1,nO); yO=x(2,nO);
        xA=x(1,nA); yA=x(2,nA);
        xB=x(1,nB); yB=x(2,nB);
        xC=x(1,nC); yC=x(2,nC);
        xD=x(1,nD); yD=x(2,nD);

        RESX=(((xA-xB)^2+(yA-yB)^2)^0.5... % length between point A and B in pixel (along axis X)
        +((xC-xD)^2+(yC-yD)^2)^0.5)/(4*dX); % length between point C and D in pixel (along axis X)

        RESY=(((xA-xD)^2+(yA-yD)^2)^0.5...
        +((xC-xB)^2+(yC-yB)^2)^0.5)/(4*dY);

        RES=(RESX+RESY)/2;
    
        message=sprintf('Resolution of rectified image will be: %0.2f pix/mm',RES); 
        disp(message)
        
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
        filename=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectification.pdf');
        %print(htemp,'-dpdf',filename)
        close(htemp)

        % create new figure with vectors from points to where it needs to
        % go
        htemp=figure(10);
        quiver(x(1,:),x(2,:),tx(1,:)-x(1,:),tx(2,:)-x(2,:),0);
        set(gca,'YDir','reverse');
        hold on;
        axis equal;
        filename=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectification-Vector.pdf');
        %print(htemp,'-dpdf',filename)
        close(htemp)
        
        message=sprintf('Calculating rectification function...'); 
        disp(message)
        
        
        if RectMethod == 1 || RectMethod == 3
            A=[x(1,1) x(2,1);x(1,(n_sq_x+1)) x(2,(n_sq_x+1));x(1,(n_sq_x+1)*(n_sq_y+1)) x(2,(n_sq_x+1)*(n_sq_y+1)); x(1,(n_sq_x+1)*(n_sq_y+1)-n_sq_x) x(2,(n_sq_x+1)*(n_sq_y+1)-n_sq_x)];
            B=[tx(1,1) tx(2,1);tx(1,(n_sq_x+1)) tx(2,(n_sq_x+1));tx(1,(n_sq_x+1)*(n_sq_y+1)) tx(2,(n_sq_x+1)*(n_sq_y+1)); tx(1,(n_sq_x+1)*(n_sq_y+1)-n_sq_x) tx(2,(n_sq_x+1)*(n_sq_y+1)-n_sq_x)];          
            RectFn=cp2tform(A,B,'projective');
        else RectMethod == 2
             RectFn=cp2tform(x',tx','polynomial',Order);
                   
        end
            
       
        
        message=sprintf('Rectifying calibration image...'); 
        disp(message)
        ImB = imtransform(I,RectFn,'bilinear','FillValues', Inf);
        
        % Save the Rectfication function
        message=sprintf('Saving rectification function...'); 
        disp(message)
        SaveFile=fullfile(TecPIVFolder,ProjectName,DataFolder,'RectificationFunction.mat');
        if exist(SaveFile,'file')
        save(SaveFile,...
            'RES',...
            'RectFn','-append');
        else
            save(SaveFile,...
            'RES',...
            'RectFn');
        end
        
        % Save the rectified calibration image in the calibration folder
        message=sprintf('Saving rectified calibration image...\n'); 
        disp(message)
        
        
        cd(fullfile(TecPIVFolder,ProjectName,DataFolder));
        mkdir('Rectified');
        cd(fullfile(TecPIVFolder,ProjectName));
        
        name=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectified',['IMG_' num2str(Frame) '.tif']);
        imwrite(ImB,name,'tiff','Compression','none');
       
    end
end

