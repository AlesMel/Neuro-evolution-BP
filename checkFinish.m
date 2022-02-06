function [finished, fit] = checkFinish(pose, checkPointsReached, fit, numChpts)
    finished = 0;
    possibleFinishes = linspace(160, 170, 11);
    if pose(1,1) == 90 && any(possibleFinishes == pose(2,1)) && checkPointsReached == numChpts - 1
        finished = 1;
        fit = fit - 100000;
    elseif pose(1,1) == 90 && any(possibleFinishes == pose(2,1)) && checkPointsReached < numChpts - 1
        fit = fit + 10;
    end
end