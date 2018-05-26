function [SDX, SDY, CropImage,rect] = TecPIV_CheckCalib(ImB,Ax,RawCpt,tx,wintx,winty,n_sq_x,n_sq_y,dX,dY,TecPIVFolder,ProjectName,DataFolder,RES,VectorField,Derivative,STEP)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

uiwait(msgbox('Checking calibration. Click the 4 corners of the calibration board...','Checking calibration','modal'));
   
%% check the accuracy of rectification
      % Display rectified image
      TecPIV_Display(TecPIVFolder,ImB,Ax,RawCpt,VectorField,Derivative);
      drawnow; hold on;
      
      % extract corner points from rectified image
      Newx= []; Newy = [];
      
      for count = 1:4,
        [xi,yi]=ginput4(1);
        [xxi]=cornerfinder([xi;yi],ImB,winty,wintx);
        xi=xxi(1);
        yi=xxi(2);
        plot(xi,yi,'+','color',[ 1.000 0.314 0.510 ],'linewidth',2);
        plot(xi + [wintx+.5 -(wintx+.5) -(wintx+.5) wintx+.5 wintx+.5],yi + [winty+.5 winty+.5 -(winty+.5) -(winty+.5)  winty+.5],'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
        Newx = [Newx;xi];
        Newy = [Newy;yi];
        plot(Newx,Newy,'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
        drawnow;
     end
        
     plot([Newx;Newx(1)],[Newy;Newy(1)],'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
     drawnow;
     hold off;
     [Xc,good,bad,type] = cornerfinder([Newx';Newy'],ImB,winty,wintx);
     
     Newx = Xc(1,:)';
     Newy = Xc(2,:)';
        
      % Sort the corners:
    x_mean = mean(Newx);
    y_mean = mean(Newy);
    x_v = Newx - x_mean;
    y_v = Newy - y_mean;

    theta = atan2(-y_v,x_v);
    [~,ind] = sort(mod(theta-theta(1),2*pi));
    ind = ind([4 3 2 1]); %-> New: the Z axis is pointing uppward

    Newx = Newx(ind);
    Newy = Newy(ind);
    x1= Newx(1); x2 = Newx(2); x3 = Newx(3); x4 = Newx(4);
    y1= Newy(1); y2 = Newy(2); y3 = Newy(3); y4 = Newy(4);
    
    % Find center:
    p_center = cross(cross([x1;y1;1],[x3;y3;1]),cross([x2;y2;1],[x4;y4;1]));
    x5 = p_center(1)/p_center(3);
    y5 = p_center(2)/p_center(3);

    % center on the X axis:
    x6 = (x3 + x4)/2;
    y6 = (y3 + y4)/2;

    % center on the Y axis:
    x7 = (x1 + x4)/2;
    y7 = (y1 + y4)/2;

    % Direction of displacement for the X axis:
    vX = [x6-x5;y6-y5];
    vX = vX / norm(vX); 
    
    % Direction of displacement for the X axis:
    vY = [x7-x5;y7-y5];
    vY = vY / norm(vY);

    % Direction of diagonal:
    vO = [x4 - x5; y4 - y5];
    vO = vO / norm(vO);
    [~,DiagCal] = cart2pol(x4 - x5,y4 - y5);
    delta = 30;
    
    % replot
    TecPIV_Display(TecPIVFolder,ImB,Ax,RawCpt,VectorField,Derivative);
    drawnow; hold on;
    plot([Newx;Newx(1)],[Newy;Newy(1)],'g-');
    
    plot(Newx,Newy,'og');
    hx=text(x6 + delta * vX(1) ,y6 + delta*vX(2),'X');
    set(hx,'color','g','Fontsize',14);
    hy=text(x7 + delta*vY(1), y7 + delta*vY(2),'Y');
    set(hy,'color','g','Fontsize',14);
    hO=text(x4 + delta * vO(1) ,y4 + delta*vO(2),'O','color','g','Fontsize',14);
    %hold off;
    
    % Compute the inside points through computation of the planar homography (collineation)
    a00 = [Newx(1);Newy(1);1];
    a10 = [Newx(2);Newy(2);1];
    a11 = [Newx(3);Newy(3);1];
    a01 = [Newx(4);Newy(4);1];
    
    % Compute the planar collineation: (return the normalization matrix as well)
    [Homo,Hnorm,inv_Hnorm] = compute_homography([a00 a10 a11 a01],[0 1 1 0;0 0 1 1;1 1 1 1]);

    % Build the grid using the planar collineation:
    x_l = ((0:n_sq_x)'*ones(1,n_sq_y+1))/n_sq_x;
    y_l = (ones(n_sq_x+1,1)*(0:n_sq_y))/n_sq_y;
    pts = [x_l(:) y_l(:) ones((n_sq_x+1)*(n_sq_y+1),1)]';

    XX = Homo*pts;
    XX = XX(1:2,:) ./ (ones(2,1)*XX(3,:));
    % Complete size of the rectangle
    Wi = n_sq_x*dX;
    Le = n_sq_y*dY;

    % plot the crosses
    plot(XX(1,:),XX(2,:),'r+');
    hold off;
    
    Np = (n_sq_x+1)*(n_sq_y+1); % number of points
    
    disp('Searching for control points...');
    grid_pts = cornerfinder(XX,ImB,winty,wintx); %% coordinates of CP in rectified image
    grid_pts = grid_pts - 1; % subtract 1 to bring the origin to (0,0) instead of (1,1) in matlab
    ind_corners = [1 n_sq_x+1 (n_sq_x+1)*n_sq_y+1 (n_sq_x+1)*(n_sq_y+1)]; % index of the 4 corners
    ind_orig = (n_sq_x+1)*n_sq_y + 1;
    xorig = grid_pts(1,ind_orig);
    yorig = grid_pts(2,ind_orig);
    dxpos = mean([grid_pts(:,ind_orig) grid_pts(:,ind_orig+1)],2);
    dypos = mean([grid_pts(:,ind_orig) grid_pts(:,ind_orig-n_sq_x-1)],2);

    x_box_kk = [grid_pts(1,:)-(wintx+.5);grid_pts(1,:)+(wintx+.5);grid_pts(1,:)+(wintx+.5);grid_pts(1,:)-(wintx+.5);grid_pts(1,:)-(wintx+.5)];
    y_box_kk = [grid_pts(2,:)-(winty+.5);grid_pts(2,:)-(winty+.5);grid_pts(2,:)+(winty+.5);grid_pts(2,:)+(winty+.5);grid_pts(2,:)-(winty+.5)];
    
    % replot
    TecPIV_Display(TecPIVFolder,ImB,Ax,RawCpt,VectorField,Derivative);
    drawnow; hold on;
    
    plot(grid_pts(1,:)+1,grid_pts(2,:)+1,'r+');
    plot(x_box_kk+1,y_box_kk+1,'-b');
    plot(grid_pts(1,ind_corners)+1,grid_pts(2,ind_corners)+1,'mo');
    plot(xorig+1,yorig+1,'*m');
    h = text(xorig+delta*vO(1),yorig+delta*vO(2),'O');
    set(h,'Color','m','FontSize',14);
    h2 = text(dxpos(1)+delta*vX(1),dxpos(2)+delta*vX(2),'dX');
    set(h2,'Color','g','FontSize',14);
    h3 = text(dypos(1)+delta*vY(1),dypos(2)+delta*vY(2),'dY');
    set(h3,'Color','g','FontSize',14);
    drawnow; hold off;  
    
      %grid_pts = cornerfinder(tx,single(ImB),winty,wintx);
        DX=tx(1,:)-grid_pts(1,:); % error X
        DY=tx(2,:)-grid_pts(2,:); % error Y
%         De=(DX.^2+DY.^2).^0.5; 
%         SDe=1.96*std(De); 
%         MDe=mean(De);
        MDX=mean(DX); SDX=1.96*std(DX);% 95% confidence limit
        MDY=mean(DY); SDY=1.96*std(DY);
        message=sprintf('Rectification error (95%% confidence interval) is:[%0.2f %0.2f] pix \n', SDX, SDY);
        disp(message)
        
        % plot a series of graphs to visualize error
        % plot rectfied grid and target grid
        h=figure(10);
%         plot(xO,yO,'Marker','o','MarkerFaceColor','red');
%         set(gca,'YDir','reverse');
%         hold on;
        plot(grid_pts(1,:),grid_pts(2,:),'+');
        hold on;
        plot(tx(1,:),tx(2,:),'+r');
        axis equal;
        filename=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectification_residual-grid.pdf');
        print(h,'-dpdf',filename)
        close(h)
    
        h=figure(10);
        quiver(tx(1,:),tx(2,:),tx(1,:)-grid_pts(1,:),tx(2,:)-grid_pts(2,:),0);
        hold on;
        set(gca,'YDir','reverse');
        axis equal;
        filename=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectification_residual-vector.pdf');
        %filename=strcat(handles.pathname,'\',handles.CurrentDataSource,'Rectification-Residual-Vector.pdf');
        print(h,'-dpdf',filename)
        close(h)
    
        h=figure(10);
        plot(DX,DY,'+');
        axis equal;
        filename=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectification_residual.pdf');
        %filename=strcat(handles.pathname,'\',handles.CurrentDataSource,'Rectification_residual.pdf');
        print(h,'-dpdf',filename)
        close(h)
    
        stx(1,:)=tx(1,:)-MDX; % target grid shifted by means of DX and DY as the center of calib may have been shifted to fit whole image into positive domaine
        stx(2,:)=tx(2,:)-MDY;
    
       
        % difference between shifted target grid and actual grid points
        % vector field to plot
        u=stx(1,:)-grid_pts(1,:);
        v=stx(2,:)-grid_pts(2,:);
    
        % get the magnitude of the vector field
        [~,z] = cart2pol(u,v);
        n_pt_x=n_sq_x+1;
        n_pt_y=n_sq_y+1;        
        Z=reshape(z,[n_pt_x,n_pt_y]);
             
        refval=max(z);
        scalelength=min(dX,dY)*RES;
        scale=refval/scalelength;

        STX = reshape(stx(1,:),[n_pt_x,n_pt_y]);
        STY = reshape(stx(2,:),[n_pt_x,n_pt_y]);
        U = reshape(u,[n_pt_x,n_pt_y]);
        V = reshape(v,[n_pt_x,n_pt_y]);
    
        h=figure(10);
%         imagesc(STX(:,1),STY(1,:),Z);
%         colorbar('location','eastoutside','CDataMapping','scaled');
%         hold on;
        ncquiverref(STX,STY,U,V,'pix','max','true','b',2)
        hold on;
        axis equal;
        filename=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectification_shifted-residual-vector.pdf');
        %filename=strcat(handles.pathname,'\',handles.CurrentDataSource,'Rectification-Shifted-Residual-Vector.pdf');
        print(h,'-dpdf',filename)
        close(h)
    
        h=figure(10);
        plot(DX-MDX,DY-MDY,'+');
        axis equal;
        filename=fullfile(TecPIVFolder,ProjectName,DataFolder,'Rectification_shifted_residual.pdf');
        %filename=strcat(handles.pathname,'\',handles.CurrentDataSource,'Rectification_shifted-residual.pdf');
        print(h,'-dpdf',filename)
        close(h)
        
        SaveFile=fullfile(TecPIVFolder,ProjectName,DataFolder,'ControlPointsRectfied_1.mat');
        
    if exist(SaveFile,'file')
        save(SaveFile,...
            ['grid_pts'],...
            ['tx'],...
            ['STX'],...
            ['STY'],...
            ['wintx'],...
            ['winty'],...
            ['dX'],...
            ['dY'],...
            ['n_sq_x'],...
            ['n_sq_y'],'-append');
    else
        save(SaveFile,...
            ['grid_pts'],...
            ['tx'],...
            ['STX'],...
            ['STY'],...
            ['wintx'],...
            ['winty'],...
            ['dX'],...
            ['dY'],...
            ['n_sq_x'],...
            ['n_sq_y']);
    end
    message=sprintf('%d control points found in calibration image %d \n',Np,i);
    disp(message);
    
    MinX=min(grid_pts(1,:));
    MaxX=max(grid_pts(1,:));
    WidthCal=MaxX-MinX;
    
    MinY=min(grid_pts(2,:));
    MaxY=max(grid_pts(2,:));
    HeightCal=MaxY-MinY;
    
    SizeImB=size(ImB);
    ImageHeight=SizeImB(1,1);
    ImageWidth=SizeImB(1,2);
    
    if STEP == 1 % if we are in last STEP
        %if (ImageHeight-HeightCal) >= 0.5*HeightCal || (ImageWidth-WidthCal) >= 0.5*WidthCal
            % Construct a questdlg with 2 options
            choice = questdlg('Rectified image is much larger than calibration board. Would you like to crop it?', ...
            'Crop Image?',...
            'Yes',...
            'No','No');
            % Handle response
            switch choice
                case 'Yes'
                CropImage = 1;
                [I2 rect] = imcrop(ImB);
                cd(fullfile(TecPIVFolder,ProjectName));
                Frame=1;
                name=fullfile(TecPIVFolder,ProjectName,DataFolder,['IMG_' num2str(Frame) '.tif']);
                imwrite(I2,name,'tiff','Compression','none');
                disp('Saving cropped image...')
            
                % load image to rectify
                FramePath=fullfile(TecPIVFolder,ProjectName,DataFolder,['IMG_' num2str(Frame) '.tif']);
                ImB=imread(FramePath);
                TecPIV_Display(TecPIVFolder,ImB,Ax,RawCpt,VectorField,Derivative);
            
                case 'No'
                CropImage = 0;
                rect=[];
            end
        %end
    else
      CropImage = 0;
      rect=[];  
    end
end

