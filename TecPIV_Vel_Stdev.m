function [u_filtered,v_filtered,typevector_filtered] = TecPIV_Vel_Stdev(u,v,typevector,ThresStd)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 % check Std
 
    u_filtered = u;
    v_filtered = v;
    typevector_filtered = typevector;
    meanu=nanmean(nanmean(u_filtered));
    meanv=nanmean(nanmean(v_filtered));
    std2u=nanstd(reshape(u_filtered,size(u_filtered,1)*size(u_filtered,2),1));
    std2v=nanstd(reshape(v_filtered,size(v_filtered,1)*size(v_filtered,2),1));
    minvalu=meanu-ThresStd*std2u;
    maxvalu=meanu+ThresStd*std2u;
    minvalv=meanv-ThresStd*std2v;
    maxvalv=meanv+ThresStd*std2v;
    u_filtered(u<minvalu)=NaN;
    u_filtered(u>maxvalu)=NaN;
    v_filtered(v<minvalv)=NaN;
    v_filtered(v>maxvalv)=NaN;
    
    typevector_filtered(u<minvalu)=4;
    typevector_filtered(u>maxvalu)=4;
    typevector_filtered(v<minvalv)=4;
    typevector_filtered(v>maxvalv)=4;
  
end