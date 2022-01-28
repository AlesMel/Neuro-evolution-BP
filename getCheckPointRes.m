function checkPoint = getCheckPointRes(pose, checkPointsReached)
       checkPoints = [120 160 0; 120 170 0; 
       158 110 0; 168 110 0; 
       80 108 0; 84 104 0;
       40 120 0; 50 120 0];

        checkPoint = 0;
    % https://matlabgeeks.com/tips-tutorials/computational-geometry/check-if-a-point-is-on-a-line-segment/
        A = checkPoints(checkPointsReached+1,:);
        B = checkPoints(checkPointsReached+2,:);

        AB = B - A;
        AC = pose' - A;

%             z = A(1)*B(2) - A(2)*B(1);
    
        if cross(AB, AC) == 0
            checkPoint = true;
        end

end