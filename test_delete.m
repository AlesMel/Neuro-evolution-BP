checkpoints = [120 160; 120 170;
               158 158; 158 168;
               158 140; 168 140;
               158 110; 168 110; 
               142 116; 142 126;
               110 118; 110 128;
               78 108; 84 104;
               58 68; 68 68;
               40 75; 50 75;
               40 115; 50 115;
               40 154; 50 154];

pose = [120; 167; 0];
i = 1;
checkPoint = 0;
% while i ~= length(checkPoints)-1
% 
%     A = checkPoints(i,:);
%     B = checkPoints(i+1,:);
%     % form vectors for the line segment (AB) and the point to one endpoint of
%     % segment
%     AB = B - A;
%     AC = pose - A;
%     z = A(1)*B(2) - A(2)*B(1);
%     i = i + 2;
% 
%     if cross(AB, AC) == 0
%         checkPoint = true;
%     end
% end


chptReached = 0;
fit = 0;
PX = pose(1,1);
PY = pose(2,1);

i = -1;

while i ~= length(checkpoints) - 1
    i = i + 2;
    
    A = checkpoints(i,:);
    B = checkpoints(i+1,:);

    if PX >= A(1,1) && PX <= B(1,1) && PY >= A(1,2) && PY <= B(1,2)
        if (chptReached + 1) == i
            chptReached = mod(chptReached + 2, length(checkPoints));
            fit = fit - 20;
        else
            fit = fit + 10;
        end
    end

end