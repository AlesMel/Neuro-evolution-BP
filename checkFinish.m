function finished = checkFinish(pose, checkPointsReached)
    finished = 0;
    possibleFinishes = linspace(160, 170, 11);
    if pose(1,1) == 90 && any(possibleFinishes == pose(2,1)) && checkPointsReached == 4
        finished = 1;
    end
end