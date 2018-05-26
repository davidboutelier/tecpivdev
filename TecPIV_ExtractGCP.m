function TecPIV_ExtractGCP( DataSets,DataSetNumber,Ax,RawCpt,n_sq_x,n_sq_y,dX,dY,VectorField,Derivative)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%DataSets;

NumberImages=DataSets{DataSetNumber,4};

DataFolder=DataSets{DataSetNumber,1}; 
TecPIVFolder=DataSets{DataSetNumber,2};
ProjectName=DataSets{DataSetNumber,3};

for i=1:NumberImages 
    FramePath=fullfile(TecPIVFolder,ProjectName,DataFolder,['IMG_' num2str(i) '.tif']);
    I=imread(FramePath);
    axes(Ax);
    TecPIV_Display(TecPIVFolder,I,Ax,RawCpt,VectorField,Derivative);
    drawnow; hold on;
    I0=single(I); %make cornerfinder work on single precision
    SizeI=size(I);
    ImageHeight=SizeI(1,1);
    ImageWidth=SizeI(1,2);
    MaxHeightWidth = max([ImageHeight ImageWidth]);
    
    winty=round(MaxHeightWidth/200);
    wintx=round(MaxHeightWidth/200);
    
    x= [];y = [];
    
     for count = 1:4,
        [xi,yi]=ginput4(1);
        [xxi]=cornerfinder([xi;yi],I0,winty,wintx);
        xi=xxi(1);
        yi=xxi(2);
        plot(xi,yi,'+','color',[ 1.000 0.314 0.510 ],'linewidth',2);
        plot(xi + [wintx+.5 -(wintx+.5) -(wintx+.5) wintx+.5 wintx+.5],yi + [winty+.5 winty+.5 -(winty+.5) -(winty+.5)  winty+.5],'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
        x = [x;xi];
        y = [y;yi];
        plot(x,y,'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
        drawnow;
     end
     plot([x;x(1)],[y;y(1)],'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
     drawnow;
     hold off;
     [Xc,good,bad,type] = cornerfinder([x';y'],I0,winty,wintx);
     
     x = Xc(1,:)';
     y = Xc(2,:)';

     ScaleW=0.5; % window size is this fraction of the average distance between the points

     wintx1= ScaleW *(x(2)-x(1))/ n_sq_x; % 
     wintx2= ScaleW *(x(3)-x(4))/ n_sq_x;

     winty1= ScaleW *(y(1)-y(4))/n_sq_y;
     winty2= ScaleW *(y(2)-y(3))/n_sq_y;

     winty=round((winty1+winty2)/2);
     wintx=round((wintx1+wintx2)/2);
    
     % Sort the corners:
    x_mean = mean(x);
    y_mean = mean(y);
    x_v = x - x_mean;
    y_v = y - y_mean;

    theta = atan2(-y_v,x_v);
    [~,ind] = sort(mod(theta-theta(1),2*pi));
    ind = ind([4 3 2 1]); %-> New: the Z axis is pointing uppward

    x = x(ind);
    y = y(ind);
    x1= x(1); x2 = x(2); x3 = x(3); x4 = x(4);
    y1= y(1); y2 = y(2); y3 = y(3); y4 = y(4);
    
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
    
    delta = 30;
    
    % replot
    TecPIV_Display(TecPIVFolder,I,Ax,RawCpt,VectorField,Derivative);
    drawnow; hold on;
    plot([x;x(1)],[y;y(1)],'g-');
    
    plot(x,y,'og');
    hx=text(x6 + delta * vX(1) ,y6 + delta*vX(2),'X');
    set(hx,'color','g','Fontsize',14);
    hy=text(x7 + delta*vY(1), y7 + delta*vY(2),'Y');
    set(hy,'color','g','Fontsize',14);
    hO=text(x4 + delta * vO(1) ,y4 + delta*vO(2),'O','color','g','Fontsize',14);
    %hold off;
    
    % Compute the inside points through computation of the planar homography (collineation)
    a00 = [x(1);y(1);1];
    a10 = [x(2);y(2);1];
    a11 = [x(3);y(3);1];
    a01 = [x(4);y(4);1];
    
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
    grid_pts = cornerfinder(XX,I0,winty,wintx);
    
    %save all_corners x y grid_pts
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
    TecPIV_Display(TecPIVFolder,I,Ax,RawCpt,VectorField,Derivative);
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
    
    Xi = reshape(((0:n_sq_x)*dX)'*ones(1,n_sq_y+1),Np,1)';
    Yi = reshape(ones(n_sq_x+1,1)*(n_sq_y:-1:0)*dY,Np,1)';
    Zi = zeros(1,Np);

    Xgrid = [Xi;Yi;Zi];

    % All the point coordinates (on the image, and in 3D) - for global optimization:
    x = grid_pts;
    X = Xgrid;

    % Saves all the data into variables:
    eval(['dX_' num2str(i) ' = dX;']);
    eval(['dY_' num2str(i) ' = dY;']);  

    eval(['wintx_' num2str(i) ' = wintx;']);
    eval(['winty_' num2str(i) ' = winty;']);

    eval(['x_' num2str(i) ' = x;']);
    eval(['X_' num2str(i) ' = X;']);

    eval(['n_sq_x_' num2str(i) ' = n_sq_x;']);
    eval(['n_sq_y_' num2str(i) ' = n_sq_y;']);
    
    % Save the Calibration points
    SaveFile=fullfile(TecPIVFolder,ProjectName,DataFolder,'CalibrationPoints.mat');
    if exist(SaveFile,'file')
        save(SaveFile,...
            ['dX_' num2str(i)],...
            ['dY_' num2str(i)],...
            ['wintx_' num2str(i)],...
            ['winty_' num2str(i)],...
            ['x_' num2str(i)],...
            ['X_' num2str(i)],...
            ['n_sq_x_' num2str(i)],...
            ['n_sq_y_' num2str(i)],'-append');
    else
        save(SaveFile,...
            ['dX_' num2str(i)],...
            ['dY_' num2str(i)],...
            ['wintx_' num2str(i)],...
            ['winty_' num2str(i)],...
            ['x_' num2str(i)],...
            ['X_' num2str(i)],...
            ['n_sq_x_' num2str(i)],...
            ['n_sq_y_' num2str(i)]);
    end
    message=sprintf('%d control points found in calibration image %d \n',Np,i);
    disp(message);
     
end


end

