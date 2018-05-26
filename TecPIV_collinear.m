function tf = collinear7(p1,p2,p3)
    mat = [p1(1)-p3(1) p1(2)-p3(2); ...
           p2(1)-p3(1) p2(2)-p3(2)];
     tf = det(mat) == 0;
end

