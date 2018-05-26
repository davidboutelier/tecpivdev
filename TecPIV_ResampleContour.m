function [ xout,yout,d ] = ResampleContour( xin,yin,N )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% close the contour, temporarily
xc = [xin(:); xin(1)];
yc = [yin(:); yin(1)];

% current spacing not equally spaced
dx = diff(xc);
dy = diff(yc);

% distances between consecutive coordiates
dS = sqrt(dx.^2+dy.^2);
dS = [0; dS];

% arc length, going along (around) snake
d = cumsum(dS);  % here is independent variable
perim = d(end);

%N = 300; % nb points
ds = perim / N; % constant distance between points
dSi = ds*(0:N).';

dSi(end) = dSi(end)-.005;

xout = interp1(d,xc,dSi);
yout = interp1(d,yc,dSi);

end

