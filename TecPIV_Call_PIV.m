function [x,y,u,v,typevector] = TecPIV_Call_PIV(DataSets,DataSetNumber,param)
%
%  from PIVLab_commandline (PIVlab) adapted to my GUI and preprocessing
% 
debug = 0; % switch to 1 for more outputs
message=sprintf('Starting PIV corelation...');
disp(message);

DataFolder=DataSets{DataSetNumber,1}; 
TecPIVFolder=DataSets{DataSetNumber,2};
ProjectName=DataSets{DataSetNumber,3};
%NumberImages = DataSets{DataSetNumber,4};
ImageWidth = DataSets{DataSetNumber,5};
ImageHeight = DataSets{DataSetNumber,6};
%TimeInc = DataSets{DataSetNumber,7};

% get start, and increment and claculate new number images and pairs
StartNumber = param{23,1};
EndNumber = param{24,1};
ImageInc = param{25,1};

%TotalNumberImages=NumberImages;
NumberImagePairs= floor((EndNumber-StartNumber)/ImageInc);
%NumberImages=NumberImagePairs+1;

AdjustContrast = param{4,1};
InverseImage = param{5,1};
SubtractBackgound = param{6,1};
GaussianWindowSize =  param{7,1};
GaussianSigma = param{8,1};

IntAreaPass1 = param{1,1};
StepPass1 = param{2,1};
SubPix = param{3,1};

NumberPass = param{11,1};
IntAreaPass2 = param{12,1};
IntAreaPass3 = param{13,1};
IntAreaPass4 = param{14,1};
WindowDeform = param{15,1};

umin = param{16,1};
umax = param{17,1};
vmin = param{18,1};
vmax = param{19,1};
ThresStd = param{20,1};
EpsMed = param{21,1};
ThresMed = param{22,1};

UseROI=param{9,1};

KernelUO=param{33,1};

if UseROI == 1
    ROI=param{26,1};
    %disp('-> Calculating initial mask.')
    Mx(1)=ROI(1)+ROI(3);
    Mx(2)=ROI(1);
    Mx(3)=ROI(1);
    Mx(4)=ROI(1)+ROI(3);


    My(1)=ROI(2)+ROI(4);
    My(2)=ROI(2)+ROI(4);
    My(3)=ROI(2);
    My(4)=ROI(2);
    
    [xout,yout,~]=TecPIV_ResampleContour(Mx,My,300);
    RoiMask=[xout,yout];
    %whos xout
    
    xi=xout; % rename for later update
    yi=yout;
    
   
    if debug == 1 
       figure(9);
       plot(xi,yi,'-')
       hold on
    end
    
        
else
    ROI=[];
    RoiMask=[];
end




%% PIV analysis loop

x=cell(NumberImagePairs,1);
y=x;
u=x;
v=x;
typevector=x; 
%counter=0;

% u_filt=cell(NumberImagePairs,1);
% v_filt=u_filt;
% typevect_filt=u_filt;

%LastImage=StartNumber+NumberImagePairs*ImageInc;
%LastImageLoop=StartNumber+(NumberImagePairs-1)*ImageInc;
        
for i=1:NumberImagePairs
    percent=i/NumberImagePairs*100;
    disp('  ')
    disp(['Image pair: ',num2str(i),'/',num2str(NumberImagePairs),' (',num2str(percent),'%)'])
    
    % read image pair  
    image1=imread(fullfile(TecPIVFolder,ProjectName,DataFolder,['IMG_' num2str(StartNumber+(i-1)*ImageInc) '.tif']));
    image2=imread(fullfile(TecPIVFolder,ProjectName,DataFolder,['IMG_' num2str(StartNumber+i*ImageInc) '.tif']));
    
    if AdjustContrast == 1 % do preprocessing
        disp('-> Preprocess images')

       if InverseImage == 1 
            image1=imcomplement(image1);
            image2=imcomplement(image2);
       end
          
       if SubtractBackgound == 1  
            hfilter=fspecial('gaussian', GaussianWindowSize, GaussianSigma);
            
            background=imfilter(image1,hfilter,'replicate');
            image1 = image1 - background;
            image1 = imadjust(image1);
            
            background=imfilter(image2,hfilter,'replicate');
            image2 = image2 - background;
            image2 = imadjust(image2);
       end

    end
    

    
    disp('-> Calculate vectors')
    [x, y, u, v, typevector] = TecPIV_FFT_multi(image1, image2, ...
        param,...
        RoiMask,...
        ROI,...
        NumberImagePairs,...
        i);
% 
%     [x, y, u, v, typevector] = TecPIV_FFT_multi (image1,image2,...
%         IntAreaPass1,...
%         StepPass1,...
%         SubPix,...
%         RoiMask,... % Mask
%         ROI,... % ROI
%         NumberPass,...
%         IntAreaPass2,...
%         IntAreaPass3,...
%         IntAreaPass4,...
%         WindowDeform,...
%         NumberImagePairs,...
%         i,...
%         param);
 
    u_filtered=u;
    v_filtered=v;
    typevector_filtered=typevector; %coming out of FFT
    S=size(u_filtered);
    N_vect=S(1,1)*S(1,2);
    
    % Check that velocities are within limits
    if param{30,1} == 1
%         if exist('typevector_filtered','var') == 0
%             typevector_filtered=typevector;
%         end
        
        [u_filtered,v_filtered,typevector_vel]=TecPIV_Vel_Limits(u_filtered,v_filtered,typevector_filtered,umin,umax,vmin,vmax);
        
        % vectors that have been filtered have typevector = 3
        N_vect_removed=sum(sum(typevector_vel == 3));
        P=N_vect_removed/N_vect*100;
        disp(['-> Filter Vmax/min - Discarded vectors: ',num2str(N_vect_removed),'/',num2str(N_vect),' (',num2str(P),'%)'])
        typevector_filtered=typevector_vel;
    end
    
    % Check that velocities do not exceed Threshold from Stdev
    if param{31,1} == 1
%         if exist('typevector_filtered','var') == 0
%             typevector_filtered=typevector;
%         end
        
        % vectors that have been filtered have typevector = 4
        [u_filtered,v_filtered,typevector_std] = TecPIV_Vel_Stdev(u_filtered,v_filtered,typevector_filtered,ThresStd);
        N_vect_removed=sum(sum(typevector_std == 4));
        P=N_vect_removed/N_vect*100;
        disp(['-> Filter Std dev - Discarded vectors: ',num2str(N_vect_removed),'/',num2str(N_vect),' (',num2str(P),'%)'])
        typevector_filtered=typevector_std;    
    end
    
    if param{32,1} == 1
%         if exist('typevector_filtered','var') == 0
%             typevector_filtered=typevector;
%         end
        [u_filtered,v_filtered,typevector_UO] = TecPIV_Universal_Outlier(u_filtered,v_filtered,typevector_filtered,EpsMed,ThresMed,KernelUO);
        
        N_vect_removed=sum(sum(typevector_UO == 5));
        P=N_vect_removed/N_vect*100;
        disp(['-> Filter Universal outliers - Discarded vectors: ',num2str(N_vect_removed),'/',num2str(N_vect),' (',num2str(P),'%)']) 
        typevector_filtered = typevector_UO;
    end
    

    
    % interpolate missing vectors
    if param{34,1} ==1
        InterpolMethod = param(35,1);
        [u_filtered,v_filtered,typevector_filtered] = TecPIV_Interp_Vectors(u_filtered,v_filtered,typevector_filtered,InterpolMethod);
        disp('-> Interpolate the discarded vectors')
    end
   
    % check again that vectors outside mask are nan
   u_filtered(typevector_filtered==2)=nan;
   v_filtered(typevector_filtered==2)=nan;
    
   if debug == 1
      htemp=figure(10);
%        subplot(2,1,1)
%         pcolor(typevector);
%         axis equal image
%         colorbar;
% %         hold on
% %         plot(xi,yi,'-')
        
%         subplot(2,1,2)
        h1 = pcolor(typevector_filtered);
        set(h1, 'EdgeColor', 'none');
        axis equal image
        colorbar;
        
        filename=fullfile(['typevector_',num2str(StartNumber+i*ImageInc),'.png']);
                print(htemp,'-dpng',filename)
        close(htemp)
   end
    
    X=x;
    Y=y;
    U=u_filtered;
    V=v_filtered; 
    typevector=typevector_filtered;

  SaveName=fullfile(TecPIVFolder,ProjectName,DataFolder, 'Vectors',['Vector_' num2str(StartNumber+i*ImageInc) '.mat']);
  save(SaveName,'X','Y','U','V','typevector'); 
  
%%  
 DeformROI =  param{10,1};
 
 if DeformROI == 1
     disp('-> Calculate deformation of ROI')
     
%      % Current ROI
%         [NX,NY] = size(X);
%         NMx=Mx;
%         NMy=My;
%     
%     % TopLine of vector field
%         TopLineV = V(1,:);
%         MoveTopLine=1*max2(TopLineV)
%     
%         NMy(1)=NMy(1)+MoveTopLine;
%         NMy(2)=NMy(1);
% 
%     % BottomLine
%         BottomLineV = V(NX,:);
%         MoveBottomLine=1*min2(BottomLineV)
%     
%         NMy(3)=NMy(3)+MoveBottomLine;
%         NMy(4)=NMy(3); 
%  
%     % left column
%         LeftColU = U(:,1);
%         MoveLeftCol=1*min2(LeftColU)
%     
%         NMx(2)=NMx(2)+MoveLeftCol;
%         NMx(3)=NMx(2);
%    
%     % right column
%         RightColU = U(:,NY);
%         MoveRightCol=1*max2(RightColU)
%     
%         NMx(1)=NMx(1)+MoveRightCol;
%         NMx(4)=NMx(1);
%         
%     % New expended ROI
%         ROI=[NMx(2), NMy(3), NMx(1)-NMx(2), NMy(1)-NMy(3)]
    
    % Calculate new RoiMask
    % disp('Calculating new mask.')
    Nxi=ones(length(xi),1);
    Nyi=ones(length(xi),1);
    %whos Nxi
    
        for k=1:length(xi)
            LX=X-xi(k);
            LY=Y-yi(k);
            %LX(isnan(V) | isnan(U))=[];
            %LY(isnan(V) | isnan(U))=[];
            [~,rho] = cart2pol(LX,LY);
            rho(isnan(V) | isnan(U))=nan;
            [~,IJ] = min2(rho); % IJ are indexes of closest vector
            Nxi(k)=xi(k)+1*U(IJ(1),IJ(2)); % new coordinate X of mask element
            
            if Nxi(k) >= ImageWidth
                Nxi(k)=ImageWidth;
            end
            if Nxi(k) <= 1
                Nxi(k)=1;
            end
            
            Nyi(k)=yi(k)+1*V(IJ(1),IJ(2));  
            if Nyi(k) >= ImageHeight
                Nyi(k)=ImageHeight;
            end
            if Nyi(k) <= 1
                Nyi(k)=1;
            end
        end
        clear LX LY rho IJ
       
        RoiMask=[Nxi,Nyi];
        ROI=[floor(min(Nxi)),floor(min(Nyi)),ceil(max(Nxi))-floor(min(Nxi)),ceil(max(Nyi))-floor(min(Nyi))];
        xi=Nxi;
        yi=Nyi;
       
        if debug == 1
            figure(9);
            plot(Nxi,Nyi,'-')
            hold on
        end
  
 end
  
end
 
end
