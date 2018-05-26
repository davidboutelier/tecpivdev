function [xtable ytable utable vtable typevector] = piv_FFTmulti (image1, image2, param, mask_inpt, roi_inpt,NumberImagePairs,CurrentPair)
% This function performs the image correlation. Adapted from pivLab 1.41
% for TecPIV GUI
%% pass on PIV parameters
int1 = param{1,1};
step1 = param{2,1};
subpixfinder = param{3,1};
passes = param{11,1};
imdeform = param{15,1};

int2 = param{12,1};
int3 = param{13,1};
int4 = param{14,1};

Step2 = param{27,1};
Step3 = param{28,1};
Step4 = param{29,1};

%% pass on parameters for filtering
% velocity filtering
umin = param{16,1};
umax = param{17,1};
vmin = param{18,1};
vmax = param{19,1};

% Std dev filtering
ThresStd = param{20,1};

% Universal outlier filtering
EpsMed = param{21,1};
ThresMed = param{22,1};
KernelUO=param{33,1};

%% start
int = int1;
step =step1;

warning off %#ok<*WNOFF> %MATLAB:log:logOfZero
if numel(roi_inpt)>0
    xroi=fix(roi_inpt(1));
    yroi=fix(roi_inpt(2));
    widthroi=fix(roi_inpt(3));
    heightroi=fix(roi_inpt(4));
    image1_roi=double(image1(yroi:yroi+heightroi,xroi:xroi+widthroi));
    image2_roi=double(image2(yroi:yroi+heightroi,xroi:xroi+widthroi));
else
    xroi=0;
    yroi=0;
    image1_roi=double(image1);
    image2_roi=double(image2);
end

gen_image1_roi = image1_roi; % for multipass
gen_image2_roi = image2_roi;

if numel(mask_inpt)>0
    mask=poly2mask(mask_inpt(:,1)-xroi, mask_inpt(:,2)-yroi,size(image1_roi,1),size(image1_roi,2));
    mask=~mask;
        
else
    mask=zeros(size(image1_roi));
end

mask(mask>1)=1;
gen_mask = mask; % for multipass

miniy=1+(ceil(int/2));
minix=1+(ceil(int/2));
maxiy=step*(floor(size(image1_roi,1)/step))-(int-1)+(ceil(int/2)); 
maxix=step*(floor(size(image1_roi,2)/step))-(int-1)+(ceil(int/2));

numelementsy=floor((maxiy-miniy)/step+1);
numelementsx=floor((maxix-minix)/step+1);

LAy=miniy;
LAx=minix;
LUy=size(image1_roi,1)-maxiy;
LUx=size(image1_roi,2)-maxix;
shift4centery=round((LUy-LAy)/2);
shift4centerx=round((LUx-LAx)/2);
% shift4center will be negative if in the unshifted case the left border 
% is bigger than the right border. the vectormatrix is hence not centered 
% on the image. the matrix cannot be shifted more towards the left border 
% because then image2_crop would have a negative index. The only way to 
% center the matrix would be to remove a column of vectors on the right 
% side. but then we weould have less data....
    
if shift4centery<0 
    shift4centery=0;
end
if shift4centerx<0 
    shift4centerx=0;
end

miniy=miniy+shift4centery;
minix=minix+shift4centerx;
maxix=maxix+shift4centerx;
maxiy=maxiy+shift4centery;

image1_roi=padarray(image1_roi,[ceil(int/2) ceil(int/2)], min(min(image1_roi)));
image2_roi=padarray(image2_roi,[ceil(int/2) ceil(int/2)], min(min(image1_roi)));
mask=padarray(mask,[ceil(int/2) ceil(int/2)],0);

if (rem(int,2) == 0) % for the subpixel displacement measurement
    SubPixOffset=1;
else
    SubPixOffset=0.5;
end
xtable=zeros(numelementsy,numelementsx);
ytable=xtable;
utable=xtable;
vtable=xtable;
typevector=ones(numelementsy,numelementsx);

%% MAINLOOP

% divide images by small pictures
% new index for image1_roi and image2_roi
s0 = (repmat((miniy:step:maxiy)'-1, 1,numelementsx) + repmat(((minix:step:maxix)-1)*size(image1_roi, 1), numelementsy,1))'; 
s0 = permute(s0(:), [2 3 1]);
s1 = repmat((1:int)',1,int) + repmat(((1:int)-1)*size(image1_roi, 1),int,1);
ss1 = repmat(s1, [1, 1, size(s0,3)])+repmat(s0, [int, int, 1]);

image1_cut = image1_roi(ss1);
image2_cut = image2_roi(ss1);

%do fft2
result_conv = fftshift(fftshift(real(ifft2(conj(fft2(image1_cut)).*fft2(image2_cut))), 1), 2);
minres = permute(repmat(squeeze(min(min(result_conv))), [1, size(result_conv, 1), size(result_conv, 2)]), [2 3 1]);
deltares = permute(repmat(squeeze(max(max(result_conv))-min(min(result_conv))),[ 1, size(result_conv, 1), size(result_conv, 2)]), [2 3 1]);
result_conv = ((result_conv-minres)./deltares)*255;

%apply mask
ii = find(mask(ss1(round(int/2+1), round(int/2+1), :)));
jj = find(mask((miniy:step:maxiy)+round(int/2), (minix:step:maxix)+round(int/2)));
typevector(jj) = 2;
result_conv(:,:, ii) = 0;

[y, x, z] = ind2sub(size(result_conv), find(result_conv==255));

 % we need only one peak from each couple pictures
[z1, zi] = sort(z);
dz1 = [z1(1); diff(z1)];
i0 = find(dz1~=0);
x1 = x(zi(i0));
y1 = y(zi(i0));
z1 = z(zi(i0));

xtable = repmat((minix:step:maxix)+int/2, length(miniy:step:maxiy), 1);
ytable = repmat(((miniy:step:maxiy)+int/2)', 1, length(minix:step:maxix));

if subpixfinder==1
    [vector] = SUBPIXGAUSS (result_conv,int, x1, y1, z1, SubPixOffset);
elseif subpixfinder==2
    [vector] = SUBPIX2DGAUSS (result_conv,int, x1, y1, z1, SubPixOffset);
end
vector = permute(reshape(vector, [size(xtable') 2]), [2 1 3]);

utable = vector(:,:,1);
vtable = vector(:,:,2);


     

%assignin('base','corr_results',corr_results);


%multipass
%feststellen wie viele passes
%wenn intarea=0 dann keinen pass.
for multipass=1:passes-1

%     if GUI_avail==1
%         set(handles.progress, 'string' , ['Frame progress: ' int2str(j/maxiy*100/passes+((multipass-1)*(100/passes))) '%' sprintf('\n') 'Validating velocity field']);drawnow;
%      else
%         fprintf('.');
%     end
    %multipass validation, smoothing
    
    % copy original tables
    utable_orig=utable;
    vtable_orig=vtable;
    
    % perform one Universal Outlier 
    [utable,vtable,typevector] = TecPIV_Universal_Outlier(utable,vtable,typevector,EpsMed,ThresMed,KernelUO);
   
    % replace nans
    utable=inpaint_nans(utable,3); % note: PIVlab uses 4
    vtable=inpaint_nans(vtable,3);
    
    
    % smooth predictor IS IT NECSSARY?
%     try
%         if multipass<passes-1
%             utable = smoothn(utable,0.6); %stronger smoothing for first passes
%             vtable = smoothn(vtable,0.6);
%         else
%             utable = smoothn(utable); %weaker smoothing for last pass
%             vtable = smoothn(vtable);
%         end
%     catch
%         
%         %old matlab versions: gaussian kernel
%         h=fspecial('gaussian',5,1);
%         utable=imfilter(utable,h,'replicate');
%         vtable=imfilter(vtable,h,'replicate');
%     end
    
    if multipass==1
        int=round(int2/2)*2;
    end
    if multipass==2
        int=round(int3/2)*2;
    end
    if multipass==3
        int=round(int4/2)*2;
    end
    step=int/2; % overlap 50% for multipass
    
    %bildkoordinaten neu errechnen:
    %roi=[];

    image1_roi = gen_image1_roi;
    image2_roi = gen_image2_roi;
    mask = gen_mask;
    
    
    miniy=1+(ceil(int/2));
    minix=1+(ceil(int/2));
    maxiy=step*(floor(size(image1_roi,1)/step))-(int-1)+(ceil(int/2)); %statt size deltax von ROI nehmen
    maxix=step*(floor(size(image1_roi,2)/step))-(int-1)+(ceil(int/2));
    
    numelementsy=floor((maxiy-miniy)/step+1);
    numelementsx=floor((maxix-minix)/step+1);
    
    LAy=miniy;
    LAx=minix;
    LUy=size(image1_roi,1)-maxiy;
    LUx=size(image1_roi,2)-maxix;
    shift4centery=round((LUy-LAy)/2);
    shift4centerx=round((LUx-LAx)/2);
    if shift4centery<0  
        shift4centery=0;
    end
    if shift4centerx<0 
        shift4centerx=0;
    end
    miniy=miniy+shift4centery;
    minix=minix+shift4centerx;
    maxix=maxix+shift4centerx;
    maxiy=maxiy+shift4centery;
    
    image1_roi=padarray(image1_roi,[ceil(int/2) ceil(int/2)], min(min(image1_roi)));
    image2_roi=padarray(image2_roi,[ceil(int/2) ceil(int/2)], min(min(image1_roi)));
    mask=padarray(mask,[ceil(int/2) ceil(int/2)],0);
    if (rem(int,2) == 0) % for the subpixel displacement measurement
        SubPixOffset=1;
    else
        SubPixOffset=0.5;
    end
    
    xtable_old=xtable;
    ytable_old=ytable;
    typevector=ones(numelementsy,numelementsx);
    xtable = repmat((minix:step:maxix), numelementsy, 1) + int/2;
    ytable = repmat((miniy:step:maxiy)', 1, numelementsx) + int/2;


    utable=interp2(xtable_old,ytable_old,utable,xtable,ytable,'*spline');
    vtable=interp2(xtable_old,ytable_old,vtable,xtable,ytable,'*spline');

    utable_1= padarray(utable, [1,1], 'replicate');
    vtable_1= padarray(vtable, [1,1], 'replicate');
    
    % add 1 line around image for border regions... linear extrap
    firstlinex=xtable(1,:);
    firstlinex_intp=interp1(1:1:size(firstlinex,2),firstlinex,0:1:size(firstlinex,2)+1,'linear','extrap');
    xtable_1=repmat(firstlinex_intp,size(xtable,1)+2,1);
    
    firstliney=ytable(:,1);
    firstliney_intp=interp1(1:1:size(firstliney,1),firstliney,0:1:size(firstliney,1)+1,'linear','extrap')';
    ytable_1=repmat(firstliney_intp,1,size(ytable,2)+2);
    
    X=xtable_1; %original locations of vectors in whole image
    Y=ytable_1;
    U=utable_1; %interesting portion of u
    V=vtable_1; % "" of v
    
    X1=X(1,1):1:X(1,end)-1; 
    Y1=(Y(1,1):1:Y(end,1)-1)';
    X1=repmat(X1,size(Y1, 1),1);
    Y1=repmat(Y1,1,size(X1, 2));

    U1 = interp2(X,Y,U,X1,Y1,'*linear');
    V1 = interp2(X,Y,V,X1,Y1,'*linear');
    
    image2_crop_i1 = interp2(1:size(image2_roi,2),(1:size(image2_roi,1))',double(image2_roi),X1+U1,Y1+V1,imdeform); %linear is 3x faster and looks ok...

    xb = find(X1(1,:) == xtable_1(1,1));
    yb = find(Y1(:,1) == ytable_1(1,1));
    
    
    % divide images by small pictures
    % new index for image1_roi
    s0 = (repmat((miniy:step:maxiy)'-1, 1,numelementsx) + repmat(((minix:step:maxix)-1)*size(image1_roi, 1), numelementsy,1))'; 
    s0 = permute(s0(:), [2 3 1]);
    s1 = repmat((1:int)',1,int) + repmat(((1:int)-1)*size(image1_roi, 1),int,1);
    ss1 = repmat(s1, [1, 1, size(s0,3)]) + repmat(s0, [int, int, 1]);
    % new index for image2_crop_i1
    s0 = (repmat(yb-step+step*(1:numelementsy)'-1, 1,numelementsx) + repmat((xb-step+step*(1:numelementsx)-1)*size(image2_crop_i1, 1), numelementsy,1))'; 
    s0 = permute(s0(:), [2 3 1]) - s0(1);
    s2 = repmat((1:2*step)',1,2*step) + repmat(((1:2*step)-1)*size(image2_crop_i1, 1),2*step,1);
    ss2 = repmat(s2, [1, 1, size(s0,3)]) + repmat(s0, [int, int, 1]);

    image1_cut = image1_roi(ss1);
    image2_cut = image2_crop_i1(ss2);

    %do fft2
    result_conv = fftshift(fftshift(real(ifft2(conj(fft2(image1_cut)).*fft2(image2_cut))), 1), 2);
    minres = permute(repmat(squeeze(min(min(result_conv))), [1, size(result_conv, 1), size(result_conv, 2)]), [2 3 1]);
    deltares = permute(repmat(squeeze(max(max(result_conv))-min(min(result_conv))), [1, size(result_conv, 1), size(result_conv, 2)]), [2 3 1]);
    result_conv = ((result_conv-minres)./deltares)*255;
    
%     % apply SNR filter
%     result_conv_mean=mean2(result_conv); % mean of correlation map
%     result_conv_std=std2(result_conv); % std of correlation map
%     SNR = ( 255 - result_conv_mean ) / result_conv_std; % signa noise ratio
%     kk = find(SNR<=3);
%     result_conv(:,:, kk) = 0;

    % apply mask
    ii = find(mask(ss1(round(int/2+1), round(int/2+1), :)));
    jj = find(mask((miniy:step:maxiy)+round(int/2), (minix:step:maxix)+round(int/2)));
    typevector(jj) = 2;
    result_conv(:,:, ii) = 0;

    [y, x, z] = ind2sub(size(result_conv), find(result_conv==255));
    [z1, zi] = sort(z);
    % we need only one peak from each couple pictures
    dz1 = [z1(1); diff(z1)];
    i0 = find(dz1~=0);
    x1 = x(zi(i0));
    y1 = y(zi(i0));
    z1 = z(zi(i0));
    
    % new xtable and ytable
    xtable = repmat((minix:step:maxix)+int/2, length(miniy:step:maxiy), 1);
    ytable = repmat(((miniy:step:maxiy)+int/2)', 1, length(minix:step:maxix));

    if subpixfinder==1
        [vector] = SUBPIXGAUSS (result_conv,int, x1, y1, z1,SubPixOffset);
    elseif subpixfinder==2
        [vector] = SUBPIX2DGAUSS (result_conv,int, x1, y1, z1,SubPixOffset);
    end
    vector = permute(reshape(vector, [size(xtable') 2]), [2 1 3]);

    utable = utable+vector(:,:,1);
    vtable = vtable+vector(:,:,2);

end

%assignin('base','pass_result',pass_result);
%__________________________________________________________________________


xtable=xtable-ceil(int/2);
ytable=ytable-ceil(int/2);

xtable=xtable+xroi;
ytable=ytable+yroi;


%profile viewer
%p = profile('info');
%profsave(p,'profile_results')

function [vector] = SUBPIXGAUSS(result_conv, int, x, y, z, SubPixOffset)
    xi = find(~((x <= (size(result_conv,2)-1)) & (y <= (size(result_conv,1)-1)) & (x >= 2) & (y >= 2)));
    x(xi) = [];
    y(xi) = [];
    z(xi) = [];
    xmax = size(result_conv, 2);
    vector = NaN(size(result_conv,3), 2);
    if(numel(x)~=0)
        ip = sub2ind(size(result_conv), y, x, z);
        %the following 8 lines are copyright (c) 1998, Uri Shavit, Roi Gurka, Alex Liberzon, Technion � Israel Institute of Technology
        %http://urapiv.wordpress.com
        f0 = log(result_conv(ip));
        f1 = log(result_conv(ip-1));
        f2 = log(result_conv(ip+1));
        peaky = y + (f1-f2)./(2*f1-4*f0+2*f2);
        f0 = log(result_conv(ip));
        f1 = log(result_conv(ip-xmax));
        f2 = log(result_conv(ip+xmax));
        peakx = x + (f1-f2)./(2*f1-4*f0+2*f2);

        SubpixelX=peakx-(int/2)-SubPixOffset;
        SubpixelY=peaky-(int/2)-SubPixOffset;
        vector(z, :) = [SubpixelX, SubpixelY];  
    end
    
function [vector] = SUBPIX2DGAUSS(result_conv, int, x, y, z, SubPixOffset)
    xi = find(~((x <= (size(result_conv,2)-1)) & (y <= (size(result_conv,1)-1)) & (x >= 2) & (y >= 2)));
    x(xi) = [];
    y(xi) = [];
    z(xi) = [];
    xmax = size(result_conv, 2);
    vector = NaN(size(result_conv,3), 2);
    if(numel(x)~=0)
        c10 = zeros(3,3, length(z));
        c01 = c10;
        c11 = c10;
        c20 = c10;
        c02 = c10;
        ip = sub2ind(size(result_conv), y, x, z);

        for i = -1:1
            for j = -1:1
                %following 15 lines based on
                %H. Nobach � M. Honkanen (2005)
                %Two-dimensional Gaussian regression for sub-pixel displacement
                %estimation in particle image velocimetry or particle position
                %estimation in particle tracking velocimetry
                %Experiments in Fluids (2005) 38: 511�515
                c10(j+2,i+2, :) = i*log(result_conv(ip+xmax*i+j));
                c01(j+2,i+2, :) = j*log(result_conv(ip+xmax*i+j));
                c11(j+2,i+2, :) = i*j*log(result_conv(ip+xmax*i+j));
                c20(j+2,i+2, :) = (3*i^2-2)*log(result_conv(ip+xmax*i+j));
                c02(j+2,i+2, :) = (3*j^2-2)*log(result_conv(ip+xmax*i+j));
                %c00(j+2,i+2)=(5-3*i^2-3*j^2)*log(result_conv_norm(maxY+j, maxX+i));
            end
        end
        c10 = (1/6)*sum(sum(c10));
        c01 = (1/6)*sum(sum(c01));
        c11 = (1/4)*sum(sum(c11));
        c20 = (1/6)*sum(sum(c20));
        c02 = (1/6)*sum(sum(c02));
        %c00=(1/9)*sum(sum(c00));

        deltax = squeeze((c11.*c01-2*c10.*c02)./(4*c20.*c02-c11.^2));
        deltay = squeeze((c11.*c10-2*c01.*c20)./(4*c20.*c02-c11.^2));
        peakx = x+deltax;
        peaky = y+deltay;

        SubpixelX = peakx-(int/2)-SubPixOffset;
        SubpixelY = peaky-(int/2)-SubPixOffset;

        vector(z, :) = [SubpixelX, SubpixelY];
    end