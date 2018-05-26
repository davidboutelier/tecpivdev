function [indSort] = NMin(dist,Npt) 
indSort = zeros(Npt,1);
    for k = 1:Npt
        [val,index] = min(dist);
        indSort(k) = index;
        dist(index) = NaN;
    end
    
end

