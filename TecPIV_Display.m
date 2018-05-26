function TecPIV_Display(TecPivFolder,I,Ax,RawCpt,VectorField,Derivative)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% I : image to be displayed
% Ax : axes
% RawCpt : Cell array with properties associated with display of raw image
% (color palette, min, max)
% VectorField: Cell array with vector field adress and properties: display Yes/No,
% Density, Scale
% Derivative: Cell array with spatial derivative of vector field: display
% Yes/No, Name of derivative, color palette, min, max, smooth

axes(Ax);
cla(Ax); % clear the axes

RawColorMapName=RawCpt{1,1};
ColorMapMin=str2double(RawCpt{1,2});
ColorMapMax=str2double(RawCpt{1,3});
RelativeMin=ColorMapMin/65536;
RelativeMax=ColorMapMax/65536;

DoScale=RawCpt{1,4};
ImScale=RawCpt{1,5}; %ImScale=6.84;
Units=RawCpt{1,6}; %Units='mm';


% adjust image to requested range
I = imadjust(I,[RelativeMin RelativeMax],[0 1]);
switch RawColorMapName
    case 'jet'
        colormap(jet);
        subimage(I,jet(65536));
    case 'gray'
        colormap(gray);
        subimage(I,gray(65536));
end

xlabel('pix');
ylabel('pix');
        
caxis([ColorMapMin ColorMapMax]);
%colorbar('location','eastoutside','CDataMapping','scaled','Limits',[ColorMapMin ColorMapMax]);
hold on;

% Check if we display the vector field
DisplayVector=VectorField{1,1};
PlotVectorAsGrid = VectorField{1,16};

DisplayDerivative=Derivative{1,1};
DerivativeName=Derivative{1,2};
RangeType=Derivative{1,3};
DeriveCpt=Derivative{1,4};

DerivAlpha = Derivative{1,7};
InterpDeriv = Derivative{1,8};% for testing
InterDerivMethod = Derivative{1,9};

Time0=VectorField{1,10};
Inc=VectorField{1,11};
Time1=Time0*Inc;

    if DisplayVector == 1 
        if PlotVectorAsGrid == 1
            VectorDensity = VectorField{1,2};
            
        else
            % plot vectors as arrows
            VectorDensity = VectorField{1,2};
            VectorDisplayMode = VectorField{1,3};
            VectorScale = VectorField{1,4};
            if strcmp(VectorDisplayMode,'max') == 0 && strcmp(VectorDisplayMode,'mean') == 0
                VectorDisplayMode=VectorScale;
            end
            
            X = VectorField{1,5};
            Y = VectorField{1,6};
            U = VectorField{1,7};
            V = VectorField{1,8};
            typevector = VectorField{1,15}; 
            
            [o,r] = cart2pol(U,V);
            VectorUnit = VectorField{1,9};
            
            % get the minmax of vector field
            xmin=min(X(1,:));
            xmax=max(X(1,:));
            ymin=min(Y(:,1));
            ymax=max(Y(:,1));
            xwidth=[xmin xmax];
            ywidth=[ymin ymax];

            DX=abs(X(1,1)-X(1,2));
            DY=abs(Y(1,1)-Y(2,1));
            
            if InterpDeriv == 1
                [HRX,HRY]=meshgrid(xmin:xmax,(ymin:ymax));
            end

            if DisplayDerivative == 1
                switch DerivativeName
                    case 'Exx'
                        [Exx,~] = gradient(U);
                        DerivField = Exx/(DX*Time1);
                        if InterpDeriv == 1
                            DerivField=interp2(X,Y,DerivField,HRX,HRY,InterDerivMethod);
                        end
                        DerivativeName = [DerivativeName '/dt'];

                        case 'Exy'
                            [~,Exy] = gradient(U);
                            DerivField = Exy/(DY*Time1);
                            if InterpDeriv == 1
                                DerivField=interp2(X,Y,DerivField,HRX,HRY,InterDerivMethod);
                            end
                            DerivativeName = [DerivativeName '/dt'];

                        case 'Eyy'
                            [~,Eyy] = gradient(V);
                            DerivField = Eyy/(DY*Time1);
                            if InterpDeriv == 1
                                DerivField=interp2(X,Y,DerivField,HRX,HRY,InterDerivMethod);
                            end
                            DerivativeName = [DerivativeName '/dt'];

                        case 'Eyx'
                            [Eyx,~] = gradient(V);
                            DerivField = Eyx/(DX*Time1);
                            if InterpDeriv == 1
                                DerivField=interp2(X,Y,DerivField,HRX,HRY,InterDerivMethod);
                            end
                            DerivativeName = [DerivativeName '/dt'];
                        
                        case 'vorticity'
                            [curlz,~]= curl(X,Y,U,V);
                            DerivField = curlz/Time1;
                            if InterpDeriv == 1
                                DerivField=interp2(X,Y,DerivField,HRX,HRY,InterDerivMethod);
                            end

                        case 'divergence'
                            div = divergence(X,Y,U,V);
                            DerivField = div/ Time1;
                            if InterpDeriv == 1
                                DerivField=interp2(X,Y,DerivField,HRX,HRY,InterDerivMethod);
                            end

                        case 'V'
                            DerivField = r/ Time1;
                            if InterpDeriv == 1
                                DerivField=interp2(X,Y,DerivField,HRX,HRY,InterDerivMethod);
                            end

                        case 'Theta'
                            DerivField = o/ Time1;
                            if InterpDeriv == 1
                                DerivField=interp2(X,Y,DerivField,HRX,HRY,InterDerivMethod);
                            end

                        case 'Vx'
                            DerivField = U/ Time1;
                            if InterpDeriv == 1
                                DerivField=interp2(X,Y,DerivField,HRX,HRY,InterDerivMethod);
                            end

                        case 'Vy'
                            DerivField = V/ Time1;
                            if InterpDeriv == 1
                                DerivField=interp2(X,Y,DerivField,HRX,HRY,InterDerivMethod);
                            end

                end
                
                      if RangeType == 1 % minmax            
                                MaxRange=max(max(DerivField));
                                MinRange=min(min(DerivField));
                                Range=[MinRange, MaxRange];

                      elseif RangeType == 2 %+- max
                                AbsMaxRange=abs(max(max(DerivField)));
                                AbsMinRange=abs(min(min(DerivField)));
                                NewMax=max([AbsMaxRange, AbsMinRange]);
                                Range=[-NewMax,NewMax];

                      else % manual mode
                          MinRange =Derivative{1,5};
                          MaxRange = Derivative{1,6};
                          Range = [MinRange, MaxRange];

                      end
                
%                          
                    DerivROI=imref2d(size(DerivField),xwidth,ywidth); %defines the xy associated with Exx

                    hDeriv=imshow(DerivField,DerivROI);
                    ListMATLABCPT={'parula','jet','hsv','hot','cool','spring','summer','autumn','winter','gray','bone','copper','pink','lines','colorcube','prism','flag','white'};
                    Lia = ismember(DeriveCpt,ListMATLABCPT);
                    if Lia == 1
                        colormap(gca,DeriveCpt)
                    else
                        load(fullfile(TecPivFolder,'toolbox','colormaps',DeriveCpt));
                        colormap(gca,RGB)
                    end
                    iDeriv=colorbar('location','westoutside'); % place color bar with real values
                    set(get(iDeriv,'child'),'YData',Range);
                    set(iDeriv,'YLim',Range);
                    %title(iDeriv,[DerivativeName '/dt']);
                    ylabel(iDeriv,DerivativeName);


                    hDeriv.AlphaData = DerivAlpha; %set transparency strain
                    %cptcmap(DeriveCpt, 'mapping', 'direct'); 

                    caxis(Range); % defines the color scale
               
            end
            
               % downsample vector field 
                nx=VectorDensity(1);
                ny=VectorDensity(2);

                X = X(1:nx:end, 1:ny:end);
                Y = Y(1:nx:end, 1:ny:end);
                U = U(1:nx:end, 1:ny:end);
                V = V(1:nx:end, 1:ny:end);
                typevector = typevector(1:nx:end, 1:ny:end);

                if strcmp(VectorUnit,'pix') == 0 
                    ImScale=VectorField{1,12};
                    U=U/(ImScale*Time1);
                    V=V/(ImScale*Time1);

                end
            
          %  typevector(typevector~=1)=0;
            
%             % plot vector from correlation
%             XC = X(typevector ==1);
%             YC = Y(typevector ==1);
%             UC = U(typevector ==1);
%             VC = V(typevector ==1);
%             
            % change to full row vector
            X=X(1,:);
            Y=(Y(:,1))';
                                   
            ncquiverref(X,Y,U,V,VectorUnit,VectorDisplayMode,'true','black',2);
            %hold on
            
% %             % plot interpolated vectors 
%             XI = X(typevector ~= 1);
%             YI = Y(typevector ~= 1);
%             UI = U(typevector ~= 1);
%             VI = V(typevector ~= 1);
%             
%             XI=XI(1,:); size(XI)
%             YI=(YI(:,1))';
%             ncquiverref(XI,YI,UI,VI,VectorUnit,VectorDisplayMode,'true','green',2);

        end
        
            % add scale bar if toggle = phys
            if strcmp(DoScale,'phys') == 1
                 % Get the current axis limits
                 xlim=get(gca,'xlim'); xp1=xlim(1); xp2=xlim(2);
                 ylim=get(gca,'ylim'); yp1=ylim(1); yp2=ylim(2);

                 % scalebar approximately 1/10 of image width
                 LengthBarPix=(xp2-xp1)/10; % initial length pix
                 LengthBarPhys=round2(LengthBarPix/ImScale,1); % closest rounded length phys
                 if LengthBarPhys > 100
                     LengthBarPhys=round2(LengthBarPhys,100);
                 elseif LengthBarPhys > 10
                     LengthBarPhys=round2(LengthBarPhys,10);
                 end
                 LengthBarPix=LengthBarPhys*ImScale; % actual length in pix of rounded length

                 reftext=[num2str(LengthBarPhys),' ',Units,' '];

                 % set padding around the scale bar
                 padx=diff(xlim)/100; 
                 pady=diff(ylim)/100;

                % Set x position of scale bar
                xend=xp2-padx;
                xstart=xend-LengthBarPix;

                % Plot reference text in lower right hand corner
                ht=text(xstart,yp1+pady,reftext,'Visible','off','Parent',gca,'FontSize',8.5,...
            'VerticalAlignment','Bottom','HorizontalAlignment','Right');
                textextent=get(ht,'Extent');

                 % Draw patch over area of vector key 
                xl=textextent(1)-padx;
                xr=xp2;
                yt=yp2; %yb=yp1;
                yb=yp2-(textextent(2)+textextent(4)+pady);%yt=textextent(2)+textextent(4)+pady;

                hp=patch([xl; xl; xr; xr],[yb; yt; yt; yb],[2; 2; 2; 2],'w', 'LineWidth',0.5,'Parent',gca);
                %uistack(hp,'bottom')

                % Redraw reference text on top of patch
                ht=text(xstart,(yb+yt)/2,2.1,reftext,'Parent',gca,'FontSize',8.5,...
             'VerticalAlignment','Middle','HorizontalAlignment','Right');
                hold on

                % Set y position of reference vector
                yend=yp2-(textextent(2)+textextent(4)/2);
                ystart=yend;

                lx = [xstart xend];
                ly = [ystart yend];
                lz = 3*ones(size(ly));

                % Plot the scalebar
                ScaleBar=line(lx,ly,lz,'LineWidth',1,'Color','black','Parent',gca);
                uistack(ScaleBar,'top')
            end   




            if DisplayVector == 1 
                set(hDeriv,'Alphadata',DerivAlpha); 
            end
    end
end

