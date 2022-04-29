function [fit, checkpointsReached, fitSep] = fitness(nn, map, car, popIndex, geneIndex)

    fitFinish = 0;
    fitChpt = 0;
    fitInside = 0;
    fitPose = 0;
    fit = 0;

    pose = [car.carPosition car.headingAngle];
    step = 0;
    finished = 0;
    checkpointsReached = 0;
    prevDist = 20;
    chpNum = map.checkpointCount + 1;

    [nn, weights] = nn.convertWeights(popIndex, geneIndex);

    while step < map.maxSteps
        step = step + 1;

        if map.checkFinish(pose) && chpNum == checkpointsReached
%             fitFinish = -1e6;
            fitFinish = -4e3;
            break;
        end
        [sensorReadings, cameraReadings] = car.getSensorReadings();
        
        if car.checkInsidePosition(pose) == 0
            fitInside = 4e3;
%             fitInside = 1e9;
            break;
        end

        switch car.sensorMode
            case 1
                [out] = nn.evaluateOutput(sensorReadings, [pi/4], weights, popIndex, geneIndex); % get output angle
            case 2
                [out] = nn.evaluateOutput(cameraReadings, [pi/4], weights, popIndex, geneIndex); % get output angle
            case 3
                [out] = nn.evaluateOutput([sensorReadings, cameraReadings'], [pi/4], weights, popIndex, geneIndex); % get output angle
        end

        car = car.update(out(1), out(2));
        pose = [car.carPosition, car.headingAngle];

        switch map.checkCheckpoints(pose, checkpointsReached)
            case 1 % reached the correct checkpoint
%                 fit = fit - 1e2;
                fit = fit - 0.1e1;
                checkpointsReached = checkpointsReached + 1;
            case 2 % reached wrong checkpoint
%                 fit = fit + 0.5e2;
                fit = fit + 0.05e1;
        end

        checkpointsRemaining = map.checkpointCount - checkpointsReached;

        currentPosition = car.getCarOccupancy(0);

%         car.drawCar();

        if currentPosition ~= 0
            fitPose = fitPose + 0.4e1;
%             fitPose = fitPose + 1e3;   
%             break;
        end
    end
    format long

    fit = fit + (step + fitPose + fitInside) * (checkpointsRemaining+2) + fitChpt + fitFinish;
%     fit = (step + fitPose + fitInside) / (checkpointsReached+1) + fitChpt + fitFinish;

    fitSep =  {fitPose, step, fitChpt, fitFinish, fitInside};
end
