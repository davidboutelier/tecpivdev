function [u_filtered,v_filtered,typevector_filtered] = TecPIV_Interp_Vectors(u_filtered,v_filtered,typevector_filtered, Interp)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%     %Interpolate missing data
%     u_filtered=inpaint_nans(u_filtered,Interp);
%     v_filtered=inpaint_nans(v_filtered,Interp);

% get the original shape of matrix
[nx,ny]=size(u_filtered);
len=nx*ny;
u(:,1)= reshape(u_filtered,len,1);
u(:,2)= reshape(v_filtered,len,1);
% 
choices={'linear','spline','kriging','plate_0','plate_1','plate_2','plate_3','spring','Average','no interp'};
t= strcmp(Interp,choices);

    if t(1,1) == 1 % --- linear
        [uo] = vector_interp_linear(u);
        u_filtered=reshape(uo(:,1)',nx,ny);
        v_filtered=reshape(uo(:,2)',nx,ny);

    elseif t(1,2) == 1  % --- cubic spline interpolation
        [uo] = vector_interp_spline(u);
        u_filtered=reshape(uo(1,:),nx,ny);
        v_filtered=reshape(uo(2,:),nx,ny);

    elseif t(1,3) == 1 % --- kriging interpolation
        [uo] = vector_interp_kriging_local(u);
        u_filtered=reshape(uo(1,:),nx,ny);
        v_filtered=reshape(uo(2,:),nx,ny);  

    elseif t(1,4) == 1 % -- plate 0
        u_filtered=inpaint_nans(u_filtered,0);
        v_filtered=inpaint_nans(v_filtered,0);

        elseif t(1,5) == 1 % -- plate 1
        u_filtered=inpaint_nans(u_filtered,1);
        v_filtered=inpaint_nans(v_filtered,1);

        elseif t(1,6) == 1 % -- plate 2
        u_filtered=inpaint_nans(u_filtered,2);
        v_filtered=inpaint_nans(v_filtered,2);

        elseif t(1,7) == 1 % -- plate 3
        u_filtered=inpaint_nans(u_filtered,3);
        v_filtered=inpaint_nans(v_filtered,3);

        elseif t(1,8) == 1 % -- spring
        u_filtered=inpaint_nans(u_filtered,4);
        v_filtered=inpaint_nans(v_filtered,4);

        elseif t(1,9) == 1 % -- Average
        u_filtered=inpaint_nans(u_filtered,5);
        v_filtered=inpaint_nans(v_filtered,5);
    end
    
    % we do not interpolate outside of the mask. if typevector =2 =>
    % outside mask, set to NaN
    
   u_filtered(typevector_filtered==2)=nan;
   v_filtered(typevector_filtered==2)=nan;
   
end

