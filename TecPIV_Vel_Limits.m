function [u_filtered,v_filtered,typevector_filtered] = TecPIV_Vel_Limits(u,v,typevector,umin,umax,vmin,vmax)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    u_filtered=u;
    v_filtered=v;
    typevector_filtered = typevector;
    
    % check velocity limits
    u_filtered(u<umin)= NaN;
    u_filtered(u>umax)= NaN;
    v_filtered(v<vmin)= NaN;
    v_filtered(v>vmax)= NaN;
    
    typevector_filtered(u<umin)=3;
    typevector_filtered(u>umax)=3;
    typevector_filtered(v<vmin)=3;
    typevector_filtered(v>vmax)=3;
end