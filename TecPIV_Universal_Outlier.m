function [u_filtered,v_filtered,typevector_filtered] = TecPIV_Universal_Outlier(u,v,typevector,EpsMed,ThresMed,Kernel_UO)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
u_filtered =u;
v_filtered = v;
typevector_filtered = typevector;

[J,I]=size(u_filtered);
    medianres=zeros(J,I);
    normfluct=zeros(J,I,2);
    b=Kernel_UO; % data-point neigborhood radius %1=3x3, 2=5x5, 3=7x7
    for c=1:2
        if c==1; 
            velcomp=u_filtered;
        else;velcomp=v_filtered;
        end %#ok<*NOSEM>
        
        for k=1+b:I-b
            for kk=1+b:J-b
                neigh=velcomp(kk-b:kk+b,k-b:k+b);
                neighcol=neigh(:);
                neighcol2=[neighcol(1:(2*b+1)*b+b);neighcol((2*b+1)*b+b+2:end)];
                med=median(neighcol2);
                fluct=velcomp(kk,k)-med;
                res=neighcol2-med;
                medianres=median(abs(res));
                normfluct(kk,k,c)=abs(fluct/(medianres+EpsMed));
            end
        end
    end
    info1=(sqrt(normfluct(:,:,1).^2+normfluct(:,:,2).^2)>ThresMed);
    u_filtered(info1==1)=NaN;
    v_filtered(info1==1)=NaN;
    typevector_filtered(info1==1)=5;
    
end


    
    %typevector_filtered(typevector{j,1}==0)=0; %restores typevector for mask