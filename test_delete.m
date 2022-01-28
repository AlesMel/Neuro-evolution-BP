checkPoints = [120 160 0; 120 170 0; 
           158 110 0; 168 110 0; 
           80 108 0; 84 104 0;
           40 120 0; 50 120 0];

pose = [120; 160; 0]'
i = 1;
checkPoint = 0;
while i ~= length(checkPoints)-1

    A = checkPoints(i,:);
    B = checkPoints(i+1,:);
    % form vectors for the line segment (AB) and the point to one endpoint of
    % segment
    AB = B - A;
    AC = pose - A;
    z = A(1)*B(2) - A(2)*B(1);
    i = i + 2;

    if cross(AB, AC) == 0
        checkPoint = true;
    end
end