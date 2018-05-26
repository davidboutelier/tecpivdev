clc
close all
clear all


NC=256;
NP=3;

% C=zeros(3,NP);
% Lab=zeros(3,NP);
for i=1:NP
    C(:,i)=uisetcolor;
    Lab(:,i)=rgb2lab(C(:,i)');
end



%pt = interparc(NC,Lab(1,:),Lab(2,:),Lab(3,:),'pchip');
pt = interparc(NC,Lab(1,:),Lab(2,:),Lab(3,:),'spline');
X=pt(:,1)';
Y=pt(:,2)';
Z=pt(:,3)';

RGB=lab2rgb([X' Y' Z']);

RGB(RGB<0)=0;
RGB(RGB>1)=1;


figure(1)
s=24;
scatter3(X,Y,Z,s)
xlabel('L*')
ylabel('a*')
zlabel('b*')
colormap(RGB)
colorbar

figure(2)
colormap(RGB)
imagesc(sineramp);
axis equal tight
colorbar



figure(3)
colormap(flipud(RGB))
imagesc(sineramp);
axis equal tight
colorbar



